//
//  JCEmojiListView.swift
//  JCMicroVideo
//
//  Created by 赵凯 on 2024/7/3.
//

import UIKit
import JXSegmentedView

class JCEmojiListView: UIView, JXSegmentedListContainerViewListDelegate {
    
    var pageIndex: Int = 0
    
    var myBlock: ((_ model: JCEmojiModel) -> Void)?
    
    var resourceArray: [JCEmojiModel] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    init(index: Int) {
        super.init(frame: .zero)
        
        pageIndex = index
        
        // 测试数据
        for index in 0...100 {
            let model = JCEmojiModel()
            model.imageName = String(format: "emoji_%d", index%5 == 0 ? 5 : index%5)
            model.emojiCode = String(format: "000%d", index%5 == 0 ? 5 : index%5)
            resourceArray.append(model)
        }
        
        setupUI()
    }
    
    func setupUI() {
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 10.adapter
        flowLayout.minimumInteritemSpacing = 10.adapter
        flowLayout.scrollDirection = .vertical;
        
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = HexColor(hex: 0xF3F5F8)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(JCEmojiCell.self, forCellWithReuseIdentifier: "JCEmojiCell")
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50.adapter, right: 0)
        return collectionView
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func listView() -> UIView {
        return self
    }
    
    func listWillAppear() {}
    func listDidAppear() {}
    func listWillDisappear() {}
    func listDidDisappear() {}
}

extension JCEmojiListView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.resourceArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: JCEmojiCell = collectionView.dequeueReusableCell(withReuseIdentifier: "JCEmojiCell", for: indexPath) as? JCEmojiCell ?? JCEmojiCell()
        cell.model = resourceArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40.adapter, height: 40.adapter)
    }
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 15.adapter, bottom: 0, right: 15.adapter)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.myBlock?(resourceArray[indexPath.row])
    }
}
