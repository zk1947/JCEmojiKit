//
//  JCDanmuInputView.swift
//  JCMicroVideo
//
//  Created by 赵凯 on 2024/7/3.
//

import UIKit

public class JCEmojiInputView: UIControl, UITextViewDelegate {

    public var isCustom: Bool = false
    
    public var myBlock: (() -> Void)?
    
    var quickEmojiArray: [JCEmojiModel] = []
    
    public init() {
        super.init(frame: .zero)
        self.backgroundColor = HexColor(hex: 0x000000, alpha: 0.3)
        self.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        initResource()
        setupUI()
    }
    
    func initResource() {
        for index in 1...6 {
            let model = JCEmojiModel(imageName: String(format: "emoji_%d", index), emojiCode: String(format: "000%d", index))
            quickEmojiArray.append(model)
        }
    }
    
    func setupUI() {
        addSubview(backView)
        backView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(85.adapter)
        }
        
        let txtBackView = UIView()
        txtBackView.backgroundColor = HexColor(hex: 0xF3F5F8)
        txtBackView.jc_cornerRadius(radius: 17.5.adapter)
        backView.addSubview(txtBackView)
        txtBackView.snp.makeConstraints { make in
            make.top.equalTo(10.adapter)
            make.left.equalTo(12.adapter)
            make.right.equalTo(-52.adapter)
            make.height.equalTo(35.adapter)
        }
        
        txtBackView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(10.adapter)
            make.right.equalTo(-10.adapter)
            make.height.equalTo(30.adapter)
        }
        
        txtBackView.addSubview(placeHolderLable)
        placeHolderLable.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(14.adapter)
            make.height.equalTo(15.adapter)
        }
        
        let keyBoardButton = UIButton()
        keyBoardButton.setImage(UIImage.jcImage("emoji_cus_keyboard"), for: .normal)
        keyBoardButton.addTarget(self, action: #selector(keyBoardButtonAction(btn:)), for: .touchUpInside)
        backView.addSubview(keyBoardButton)
        keyBoardButton.snp.makeConstraints { make in
            make.right.equalTo(-12.adapter)
            make.centerY.equalTo(txtBackView)
            make.size.equalTo(CGSize(width: 24.adapter, height: 24.adapter))
        }
        
        let space = (Double(kScreenWidth)-24.adapter*6.0-18.adapter*2.0)/5.0
        for (index, item) in quickEmojiArray.enumerated() {
            let button = UIButton()
            button.setImage(UIImage.jcImage(item.imageName ?? ""), for: .normal)
            button.addTarget(self, action: #selector(emojiButtonAction(btn:)), for: .touchUpInside)
            button.tag = 2024+index
            backView.addSubview(button)
            button.snp.makeConstraints { make in
                make.left.equalTo(18.adapter+(space+23.adapter)*Double(index))
                make.bottom.equalTo(-10.adapter)
                make.width.height.equalTo(24.adapter)
            }
        }
    }
    
    @objc func keyBoardButtonAction(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        if btn.isSelected { // 显示自定义键盘
            isCustom = true
            textView.inputView = myKeyboardView
            self.textView.reloadInputViews()
            btn.setImage(UIImage.jcImage("emoji_sys_keyboard"), for: .normal)
        } else { // 显示系统键盘
            isCustom = false
            self.textView.inputView = nil
            self.textView.reloadInputViews()
            btn.setImage(UIImage.jcImage("emoji_cus_keyboard"), for: .normal)
        }
    }
    
    // 快捷插入表情
    @objc func emojiButtonAction(btn: UIButton) {
        addEmoji(model: quickEmojiArray[btn.tag - 2024])
    }
    
    // 发送
    func sendAction() {
        self.myBlock?()
    }
    
    @objc func dismiss() {
        textView.resignFirstResponder()
    }
    
    @objc func nothing() {
        
    }
    
    lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(nothing))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    public lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = HexColor(hex: 0xF3F5F8)
        textView.font = JCFont(13)
        textView.textColor = HexColor(hex: 0x2C2E3D)
        textView.returnKeyType = .send
        textView.tintColor = HexColor(hex: 0xFD2C55)
        textView.delegate = self
        return textView
    }()
    
    lazy var placeHolderLable: UILabel = {
        let lable = UILabel()
        lable.text = "请输入内容~"
        lable.textColor = HexColor(hex: 0x939393)
        lable.font = JCFont(13)
        return lable
    }()
    
    lazy var myKeyboardView: JCEmojiKeyBoardView = {
        let view = JCEmojiKeyBoardView()
        view.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 250.adapter)
        view.myBlock = { [weak self] model in
            guard let self = self else { return }
            self.addEmoji(model: model)
        }
        view.sendBlock = { [weak self] in
            guard let self = self else { return }
            self.myBlock?()
        }
        view.deleteBlock = { [weak self] in
            guard let self = self else { return }
            self.deleteAction()
        }
        return view
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addEmoji(model: JCEmojiModel) {
        guard UIImage(named: model.imageName ?? "") != nil else { return }
        let selectedRange = self.textView.selectedRange
        let emojiString = String(format: "[%@]", model.emojiCode ?? "")
        let emojiAttributedString = NSMutableAttributedString(string: emojiString)
        emojiAttributedString.setTextBackedString(textBackedString: JCTextBackedString(string: emojiString), range: NSRange(location: 0, length: emojiAttributedString.length))
        let attributedText = NSMutableAttributedString(attributedString: self.textView.attributedText)
        attributedText.replaceCharacters(in: selectedRange, with: emojiAttributedString)
        self.textView.attributedText = attributedText
        self.textView.selectedRange = NSRange(location: selectedRange.location + emojiAttributedString.length, length: 0)
        self.refreshTextUI()
        self.setPlaceStatus()
    }
    
    func refreshTextUI() {
        if self.textView.text.count == 0 { return }
        let markedTextRange = self.textView.markedTextRange
        _ = self.textView.position(from: markedTextRange?.start ?? UITextPosition(), offset: 0)
        if markedTextRange != nil { return }
        let selectedRange = self.textView.selectedRange
        let plainText = self.textView.attributedText.plainTextForRange(range: NSRange(location: 0, length: self.textView.attributedText.length))
        let attributedComment = NSMutableAttributedString(string: plainText, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.black])
        JCEmojiDataManager.shared.replaceEmojiForAttributedString(attributedString: attributedComment, font: UIFont.systemFont(ofSize: 14))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        attributedComment.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedComment.length))
        let offset = self.textView.attributedText.length - attributedComment.length
        self.textView.attributedText = attributedComment
        self.textView.selectedRange = NSRange(location: selectedRange.location - offset, length: 0)
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        self.refreshTextUI()
        self.setPlaceStatus()
    }
    
    func setPlaceStatus() {
        self.placeHolderLable.isHidden = textView.text.isEmpty == false
    }
    
    // 判断是否是键盘的Send按钮被点击
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {// Send按钮被点击
            sendAction()
            return false // 通常情况下返回false，以防止换行
        }
        return true
    }
    
    /// 清空内容
    public func cleanText() {
        self.textView.text = ""
        self.textView.attributedText = NSMutableAttributedString(string: "")
        self.setPlaceStatus()
        self.textView.inputView = nil
        self.isCustom = false
    }
    
    func deleteAction() {
        textView.deleteBackward()
    }
}
