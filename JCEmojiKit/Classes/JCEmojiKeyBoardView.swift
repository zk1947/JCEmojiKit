//
//  JCEmojiKeyBoardView.swift
//  JCMicroVideo
//
//  Created by 赵凯 on 2024/7/3.
//

import UIKit
import JXSegmentedView

class JCEmojiKeyBoardView: UIView {

    var myBlock: ((_ model: JCEmojiModel) -> Void)?
    
    var sendBlock: (() -> Void)?
    
    var deleteBlock: (() -> Void)?
    
    var titles: [String] = []
    
    var listViews: [JCEmojiListView] = []
    
    init() {
        super.init(frame: .zero)
        initResource()
        setupUI()
    }
    
    func initResource() {
        titles = ["emoji_1","emoji_2","emoji_3"]
        for index in titles.indices {
            let pageView = JCEmojiListView(index: index)
            pageView.myBlock = { [weak self] model in
                guard let self = self else { return }
                self.myBlock?(model)
            }
            listViews.append(pageView)
        }
    }
    
    func setupUI() {
        segmentedView.dataSource = self.segmentedDataSource
        segmentedView.listContainer = listContainerView
        segmentedView.indicators = [indicator]
        self.addSubview(segmentedView)
        segmentedView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(44.adapter)
        }
        
        self.addSubview(listContainerView)
        listContainerView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(segmentedView.snp.bottom)
        }
        
        let footView = UIView()
        addSubview(footView)
        footView.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.width.equalTo(130.adapter)
            make.height.equalTo(50.adapter)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1, execute: {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [HexColor(hex: 0xFFFFFF, alpha: 0.0).cgColor, HexColor(hex: 0xFFFFFF, alpha: 0.1).cgColor, HexColor(hex: 0xFFFFFF, alpha: 1.0).cgColor]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)
            gradientLayer.frame = footView.bounds
            footView.layer.addSublayer(gradientLayer)
        })
        
        addSubview(sendButton)
        sendButton.snp.makeConstraints { make in
            make.right.equalTo(-10.adapter)
            make.top.equalTo(footView.snp.top).offset(15.adapter)
            make.width.equalTo(50.adapter)
            make.height.equalTo(24.adapter)
        }
        
        addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.right.equalTo(sendButton.snp.left).offset(-10.adapter)
            make.top.equalTo(sendButton)
            make.width.equalTo(50.adapter)
            make.height.equalTo(24.adapter)
        }
    }
    
    lazy var segmentedView: JXSegmentedView = {
        let segmentedView = JXSegmentedView()
        segmentedView.backgroundColor = .white
        segmentedView.delegate = self
        return segmentedView
    }()
    
    lazy var indicator: JXSegmentedIndicatorBackgroundView = {
        let indicator = JXSegmentedIndicatorBackgroundView()
        indicator.indicatorHeight = 30
        indicator.indicatorColor = HexColor(hex: 0x000000, alpha: 0.1)
        return indicator
    }()
    
    lazy var segmentedDataSource: JXSegmentedTitleImageDataSource = {
        let segmentedDataSource = JXSegmentedTitleImageDataSource()
        segmentedDataSource.titleImageType = .onlyImage
        segmentedDataSource.titles = titles
        segmentedDataSource.normalImageInfos = titles
        segmentedDataSource.selectedImageInfos = titles
        segmentedDataSource.isItemSpacingAverageEnabled = false
        segmentedDataSource.loadImageClosure = {(imageView, normalImageInfo) in
            imageView.image = UIImage(named: normalImageInfo)
        }
        return segmentedDataSource
    }()
    
    lazy var listContainerView: JXSegmentedListContainerView = {
        let listContainerView = JXSegmentedListContainerView(dataSource: self)
        return listContainerView
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("删除", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = JCFont(12)
        button.addTarget(self, action: #selector(deleteButtonAction), for: .touchUpInside)
        button.backgroundColor = HexColor(hex: 0xFD2C55)
        button.jc_cornerRadius(radius: 12.adapter)
        return button
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("发送", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = JCFont(12)
        button.addTarget(self, action: #selector(sendButtonAction), for: .touchUpInside)
        button.backgroundColor = HexColor(hex: 0xFD2C55)
        button.jc_cornerRadius(radius: 12.adapter)
        return button
    }()
    
    @objc func deleteButtonAction() {
        self.deleteBlock?()
    }
    
    @objc func sendButtonAction() {
        self.sendBlock?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension JCEmojiKeyBoardView: JXSegmentedViewDelegate, JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return titles.count
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        return listViews[index]
    }
}
