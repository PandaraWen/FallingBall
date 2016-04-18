//
//  BallModel.swift
//  FallingBall
//
//  Created by Pandara on 16/1/6.
//  Copyright © 2016年 Pandara. All rights reserved.
//

import UIKit

class BallVelocityModel: NSObject {
    var angle: Float = 0
    var value: Float = 0
}

class BallCenterModel: NSObject {
    var x: Float = 0
    var y: Float = 0
}

class BallColorModel: NSObject {
    var r: Float = 0
    var g: Float = 0
    var b: Float = 0
}

class BallModel: NSObject {
    let velocity = BallVelocityModel()
    let center = BallCenterModel()
    let color = BallColorModel()
}
