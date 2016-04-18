//
//  FBToolKit.swift
//  FallingBall
//
//  Created by Pandara on 16/1/6.
//  Copyright © 2016年 Pandara. All rights reserved.
//

import UIKit

class FBToolKit: NSObject {
    static func getCupViewCon() -> CupViewController {
        let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        return appDelegate.cupViewCon
    }
}
