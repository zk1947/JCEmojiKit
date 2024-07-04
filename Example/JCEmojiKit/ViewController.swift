//
//  ViewController.swift
//  JCEmojiKit
//
//  Created by zk1947@163.com on 07/04/2024.
//  Copyright (c) 2024 zk1947@163.com. All rights reserved.
//

import UIKit
import SnapKit
import JCEmojiKit

class ViewController: UIViewController {

    deinit {
        removeObserver()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObserver()
        
        let lable = UILabel()
        lable.text = "字符串编码："
        lable.textColor = .black
        lable.font = JCFont(18)
        view.addSubview(lable)
        lable.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(50)
        }
        
        view.addSubview(lable1)
        lable1.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(lable.snp.bottom).offset(20)
        }
        
        let lable6 = UILabel()
        lable6.text = "富文本结果："
        lable6.textColor = .black
        lable6.font = JCFont(18)
        view.addSubview(lable6)
        lable6.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(lable1.snp.bottom).offset(30)
        }
        
        view.addSubview(lable2)
        lable2.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(lable6.snp.bottom).offset(20)
        }
        
        let button = UIButton()
        button.setImage(UIImage.jcImage("emoji_1"), for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        view.addSubview(danmuInputView)
        danmuInputView.frame = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: kScreenHeight)
    }
    
    lazy var lable1: UILabel = {
        let lable = UILabel()
        lable.textColor = .black
        lable.font = JCFont(14)
        lable.numberOfLines = 0
        return lable
    }()
    
    lazy var lable2: UILabel = {
        let lable = UILabel()
        lable.textColor = .black
        lable.font = JCFont(14)
        lable.numberOfLines = 0
        return lable
    }()
    
    @objc func buttonAction() {
        danmuInputView.textView.becomeFirstResponder()
    }
    
    func send() {
        if danmuInputView.textView.text.isEmpty { return }
        let result = danmuInputView.textView.attributedText.plainTextForRange(range: NSRange(location: 0, length: danmuInputView.textView.attributedText.length))
        lable1.text = result
        
        let attributedMessage = NSMutableAttributedString(string: result, attributes: [NSAttributedString.Key.font: JCFont(14), NSAttributedString.Key.foregroundColor: UIColor.black])
        JCEmojiDataManager.shared.replaceEmojiForAttributedString(attributedString: attributedMessage, font: JCFont(14))
        lable2.attributedText = attributedMessage
    }
    
    lazy var danmuInputView: JCEmojiInputView = {
        let view = JCEmojiInputView()
        view.myBlock = { [weak self] in
            guard let self = self else { return }
            self.send()
        }
        return view
    }()
    
}

extension ViewController {
    // 监听键盘
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    // 移除监听
    func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // 键盘即将弹出时调用的方法
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            let animationDuration = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? Double ?? 0.3
            UIView.animate(withDuration: animationDuration) {
                if self.danmuInputView.isCustom {
                    self.danmuInputView.textView.reloadInputViews()
                    self.danmuInputView.isCustom = false
                }
                self.danmuInputView.frame = CGRect(x: 0, y: -keyboardHeight, width: kScreenWidth, height: kScreenHeight)
            }
        }
    }

    // 键盘即将隐藏时调用的方法
    @objc func keyboardWillHide(notification: Notification) {
        let animationDuration = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? Double ?? 0.3
        UIView.animate(withDuration: animationDuration) {
            self.danmuInputView.frame = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: kScreenHeight)
        }
        // 清空
        self.danmuInputView.cleanText()
    }
}

