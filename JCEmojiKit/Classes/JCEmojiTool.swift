//
//  JCEmojiTool.swift
//  JCEmojiKit
//
//  Created by 赵凯 on 2024/7/4.
//

import Foundation
@_exported import SnapKit

public let kScreenWidth = UIScreen.main.bounds.width

public let kScreenHeight = UIScreen.main.bounds.height

public func HexColor(hex: integer_t) -> UIColor {
    return UIColor(red: CGFloat((hex >> 16) & 0xff)/255.0, green: CGFloat((hex >> 8) & 0xff)/255.0, blue: CGFloat(hex & 0xff)/255.0, alpha: 1)
}

public func HexColor(hex: integer_t, alpha: CGFloat) -> UIColor {
    return UIColor(red: CGFloat((hex >> 16) & 0xff)/255.0, green: CGFloat((hex >> 8) & 0xff)/255.0, blue: CGFloat(hex & 0xff)/255.0, alpha: alpha)
}

public func JCFont(_ size: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size, weight: .regular)
}

public extension UIView {
    func jc_cornerRadius(radius: CGFloat) {
        self.layer.masksToBounds = true
        self.layer.cornerRadius  = radius
    }
}

public extension UIImage {
    class func jcImage(_ name: String) -> UIImage {
        return UIImage(named: name) ?? UIImage()
    }
}

extension String {
    /// 字符串区间截取
    func substring(with range: NSRange) -> String? {
        guard let range = Range(range, in: self) else {
            return nil
        }
        return String(self[range])
    }
    /// 字符串去掉首位字符
    func removingFirstAndLastCharacters() -> String {
        guard self.count > 1 else {
            return self
        }
        return String(self.dropFirst().dropLast())
    }
}

extension NSRegularExpression {
    class func creat(pattern: String, options: NSRegularExpression.Options = []) -> NSRegularExpression? {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: options)
            return regex
        } catch let error as NSError {
            print("Error creating regular expression: \(error.localizedDescription)")
            return nil
        }
    }
}

public extension NSAttributedString {
    func plainTextForRange(range: NSRange) -> String {
        if range.location == NSNotFound || range.length == NSNotFound {return ""}
        var result: String = ""
        self.enumerateAttribute(NSAttributedString.Key(rawValue: EmojiAttributeName), in: range) { value, range, stop in
            if let rvalue = value as? JCTextBackedString {
                result.append(rvalue.string ?? "")
            } else {
                result.append(self.string.substring(with: range) ?? "")
            }
        }
        return result
    }
}

extension NSMutableAttributedString {
    func setTextBackedString(textBackedString: JCTextBackedString, range: NSRange) {
        if (textBackedString.string?.count ?? 0) > 0 {
            self.addAttribute(NSAttributedString.Key.init(rawValue: EmojiAttributeName), value: textBackedString, range: range)
        } else {
            self.removeAttribute(NSAttributedString.Key.init(rawValue: EmojiAttributeName), range: range)
        }
    }
}

class JCTextBackedString: NSObject, NSCoding, NSCopying {
    var string: String?
    
    init(string: String) {
        super.init()
        self.string = string
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let string = aDecoder.decodeObject(forKey: "string") as? String else {
            return nil
        }
        self.init(string: string)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(string, forKey: "string")
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = JCTextBackedString(string: self.string ?? "")
        return copy
    }
}

/** 要适配的类型
 * Int
 * CGFloat
 * Double
 * Float
 * CGSize
 * CGRect
 */

public struct Adapter {
    public static var share = Adapter()
    
    /// 参考标准（UI是以哪个屏幕设计UI的）
    public var base: Double = 375
    
    /// 记录适配比例
    fileprivate var adapterScale: Double?
}

public protocol Adapterable {
    associatedtype AdapterType
    var adapter: AdapterType { get }
}

extension Adapterable {
    func adapterScale() -> Double {
        
        if let scale = Adapter.share.adapterScale {
            return scale
        } else {
            let width = UIScreen.main.bounds.size.width
            /// 参考标准以 iPhone 6 的宽度为基准
            let referenceWidth: Double = Adapter.share.base
            let scale = width / referenceWidth
            Adapter.share.adapterScale = scale
            return scale
        }
    }
}

extension Int: Adapterable {
    public typealias AdapterType = Int
    public var adapter: Int {
        let scale = adapterScale()
        let value = Double(self) * scale
        return Int(value)
    }
}

extension CGFloat: Adapterable {
    public typealias AdapterType = CGFloat
    public var adapter: CGFloat {
        let scale = adapterScale()
        let value = self * scale
        return value
    }
}

extension Double: Adapterable {
    public typealias AdapterType = Double
    public var adapter: Double {
        let scale = adapterScale()
        let value = self * scale
        return value
    }
}

extension Float: Adapterable {
    public typealias AdapterType = Float
    public var adapter: Float {
        let scale = adapterScale()
        let value = self * Float(scale)
        return value
    }
}

extension CGSize: Adapterable {
    public typealias AdapterType = CGSize
    public var adapter: CGSize {
        let scale = adapterScale()
        
        let width = self.width * scale
        let height = self.height * scale
        
        return CGSize(width: width, height: height)
    }
}

extension CGRect: Adapterable {
    public typealias AdapterType = CGRect
    public var adapter: CGRect {

        /// 不参与屏幕rect
        if self == UIScreen.main.bounds {
            return self
        }

        let scale = adapterScale()
        let x = origin.x * scale
        let y = origin.y * scale
        let width = size.width * scale
        let height = size.height * scale
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
