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
}
