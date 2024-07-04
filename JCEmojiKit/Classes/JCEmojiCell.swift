//
//  JCEmojiCell.swift
//  JCMicroVideo
//
//  Created by 赵凯 on 2024/7/3.
//

import UIKit

class JCEmojiCell: UICollectionViewCell {
    var model: JCEmojiModel? {
        didSet {
            icon.image = UIImage(named: model?.imageName ?? "")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24.adapter)
        }
    }
    
    lazy var icon: UIImageView = {
        let view = UIImageView()
        return view
    }()
}
