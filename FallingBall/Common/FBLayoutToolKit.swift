//
//  FBLayoutToolKit.swift
//  FallingBall
//
//  Created by Pandara on 15/12/30.
//  Copyright © 2015年 Pandara. All rights reserved.
//

import UIKit

let ScreenSize = UIScreen.mainScreen().bounds.size

class FBLayoutToolKit: NSObject {
    class func color(r: Int, g: Int, b: Int, a: Float) -> UIColor {
        let max : CGFloat = 255
        let theColor = UIColor(red: CGFloat(r) / max, green: CGFloat(g) / max, blue: CGFloat(b) / max, alpha: CGFloat(a))
        return theColor
    }
    
    class func hexStringFromColor(color: UIColor) -> NSString {
        let components = CGColorGetComponents(color.CGColor)
        
        let r: CGFloat = components[0]
        let g: CGFloat = components[1]
        let b: CGFloat = components[2]
        
        let hexString = String(format: "#%02lX%02lX%02lX", lround(Double(r) * 255), lround(Double(g) * 255), lround(Double(b) * 255))
        
        return hexString
    }
    
    class func colorWithHexString(hexString: String) -> UIColor {
        let colorString: String = hexString.stringByReplacingOccurrencesOfString("#", withString: "")
        
        let alpha: CGFloat = 1.0
        let red: CGFloat = FBLayoutToolKit.colorComponent(fromString: colorString, withStartIndex: 0, length: 2)
        let green: CGFloat = FBLayoutToolKit.colorComponent(fromString: colorString, withStartIndex: 2, length: 2)
        let blue: CGFloat = FBLayoutToolKit.colorComponent(fromString: colorString, withStartIndex: 4, length: 2)
        
        let color: UIColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    internal class func colorComponent(fromString string: String, withStartIndex startIndex: Int, length: Int) -> CGFloat {
        let range = string.startIndex.advancedBy(startIndex)..<string.startIndex.advancedBy(startIndex + length)
        let subString = string.substringWithRange(range)
        let fullHex = length == 2 ? subString : String(format: "%@%@", subString, subString)
        
        var hexComponent: UInt32 = 0
        NSScanner(string: fullHex).scanHexInt(&hexComponent)
        
        let hex: CGFloat = CGFloat(hexComponent) / 255.0
        return hex
    }
}
