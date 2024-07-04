//
//  JCEmojiModel.swift
//  JCMicroVideo
//
//  Created by 赵凯 on 2024/7/3.
//

import UIKit

public class JCEmojiModel: NSObject {

    var imageName: String?
    
    var emojiCode: String?
    
    convenience init(imageName: String? = nil, emojiCode: String? = nil) {
        self.init()
        self.imageName = imageName
        self.emojiCode = emojiCode
    }
}

public class JCEmojiMatchingResult: NSObject {
    /// 匹配到的表情包文本的range
    var range: NSRange?
    
    /// 如果能在本地找到emoji的图片，则此值不为空
    var emojiImage: UIImage?
    
    /// 表情的实际文本(形如：[哈哈])，不为空
    var emojiString: String?
}
