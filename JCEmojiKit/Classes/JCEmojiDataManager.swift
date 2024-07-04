//
//  JCEmojiDataManager.swift
//  JHProject
//
//  Created by 赵凯 on 2024/6/28.
//

import UIKit

let EmojiAttributeName = "EmojiAttributeName"

public class JCEmojiDataManager: NSObject {

    static public let shared = JCEmojiDataManager()
    
    var allEmojis: [JCEmojiModel] = []
    
    override init() {
        super.init()
        initEmojiDataSource()
    }
    
    /// 初始化数据源
    func initEmojiDataSource() {
        let array: [[String: Any]] = readPlistFile(named: "JCEmojiDataList")
        for item in array {
            let model = JCEmojiModel()
            model.imageName = item["imageName"] as? String
            model.emojiCode = item["emojiCode"] as? String
            allEmojis.append(model)
        }
    }
    
    /// 匹配给定attributedString中的所有emoji，如果匹配到的emoji有本地图片的话会直接换成本地的图片
    public func replaceEmojiForAttributedString(attributedString: NSMutableAttributedString, font: UIFont) {
        if attributedString.length == 0 { return }
        let array = self.matchingEmojiForString(string: attributedString.string)
        if array.count > 0 {
            var offset: Int = 0
            for emojiResult in array {
                if let image = emojiResult.emojiImage {
                    let emojiHeight = font.lineHeight
                    let attachment = NSTextAttachment()
                    attachment.image = image
                    attachment.bounds = CGRect(x: 0, y: font.descender, width: emojiHeight, height: emojiHeight)
                    let emojiAttributedString = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
                    emojiAttributedString.setTextBackedString(textBackedString: JCTextBackedString(string: emojiResult.emojiString ?? ""), range: NSRange(location: 0, length: emojiAttributedString.length))
                    let location = emojiResult.range?.location ?? 0
                    let actualRange = NSRange(location: location - offset, length: emojiResult.emojiString?.count ?? 0)
                    attributedString.replaceCharacters(in: actualRange, with: emojiAttributedString)
                    let emojiStringLenth = emojiResult.emojiString?.count ?? 0
                    offset += emojiStringLenth - emojiAttributedString.length
                    
                }
            }
        }
    }
    
    /// 将字符串中所有emoji遍历出来
    public func matchingEmojiForString(string: String?) -> [JCEmojiMatchingResult] {
        var result: [JCEmojiMatchingResult] = []
        guard let realString = string else {
            return result
        }
        guard let regex = NSRegularExpression.creat(pattern: "\\[(.+?)\\]", options: [.dotMatchesLineSeparators, .useUnicodeWordBoundaries]) else {
            return result
        }
        let nsString = realString as NSString
        let array = regex.matches(in: realString, options: [], range: NSRange(location: 0, length: nsString.length))
        if array.count > 0 {
            for item in array {
                let emojiString = realString.substring(with: item.range)
                let emojiCode = emojiString?.removingFirstAndLastCharacters()
                guard let model = getEmojiModelWithCode(code: emojiCode ?? "") else {
                    return result
                }
                let emojiResult = JCEmojiMatchingResult()
                emojiResult.range = item.range
                emojiResult.emojiString = emojiString
                if let image = UIImage(named: model.imageName ?? "") {
                    emojiResult.emojiImage = image //UIImage(named: model.imageName ?? "")
                }
                result.append(emojiResult)
            }
            return result
        }
        return result
    }
    
    /// 通过emojiCode获取对应的emoji
    public func getEmojiModelWithCode(code: String) -> JCEmojiModel? {
        for model in allEmojis where model.emojiCode == code {
            return model
        }
        return nil
    }
    
    /// 读取本地plist文件
    func readPlistFile(named fileName: String) -> [[String: Any]] {
        // 获取项目中的 Bundle 对象
        let bundle = JCEmojiKit.resouseBundle //Bundle.main
        // 获取 plist 文件的路径
        guard let filePath = JCEmojiKit.path(resource: fileName, ofType: "plist") else {
            print("文件路径未找到")
            return []
        }
        // 读取 plist 文件的内容
        guard let fileData = FileManager.default.contents(atPath: filePath) else {
            print("文件内容读取失败")
            return []
        }
        // 解析 plist 文件的内容为字典
        do {
            let plist = try PropertyListSerialization.propertyList(from: fileData, options: [], format: nil)
            return plist as? [[String: Any]] ?? []
        } catch {
            print("解析 plist 文件失败: \(error)")
            return []
        }
    }
}

open class JCEmojiKit: NSObject {
    
    /// 当前项目bundle
    static var bundle: Bundle {
        return Bundle(for: JCEmojiKit.self)
    }
    
    /// 获取bundle中文件路径
    static func path(resource: String, ofType: String) -> String? {
        return bundle.path(forResource: resource, ofType: ofType)
    }
    
    static var resouseBundle: Bundle? {
        if let budl = self.path(resource: "JCVideoModule", ofType: "bundle") {
            return Bundle(path: budl)
        }else {
            return nil
        }
    }
}
