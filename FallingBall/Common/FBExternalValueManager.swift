//
//  FBExternalValueManager.swift
//  FallingBall
//
//  Created by Pandara on 16/1/6.
//  Copyright © 2016年 Pandara. All rights reserved.
//

import UIKit

enum FBBlueToothRole : Int {
    case Undefine
    case Central
    case Peripheral
}

class FBExternalValueManager: NSObject {
    static let shareManager = FBExternalValueManager()
    var blueToothRole = FBBlueToothRole.Undefine
    
    override init() {
        
    }
}
