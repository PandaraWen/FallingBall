//
//  BallView.swift
//  FallingBall
//
//  Created by Pandara on 16/1/5.
//  Copyright © 2016年 Pandara. All rights reserved.
//

import UIKit

let BALLW: CGFloat = 50
let BALL_COLOR_ARRAY = [
    FBLayoutToolKit.color(240, g: 92, b: 88, a: 1),
    FBLayoutToolKit.color(230, g: 133, b: 53, a: 1),
    FBLayoutToolKit.color(255, g: 214, b: 69, a: 1),
    FBLayoutToolKit.color(46, g: 204, b: 113, a: 1),
    FBLayoutToolKit.color(26, g: 188, b: 156, a: 1),
    FBLayoutToolKit.color(52, g: 152, b: 219, a: 1),
    FBLayoutToolKit.color(155, g: 101, b: 182, a: 1),
    FBLayoutToolKit.color(52, g: 72, b: 94, a: 1),
]

class BallView: UIView {
    var ballBehavior: UIDynamicItemBehavior!
    
    @available(iOS 9.0, *)
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        get {
            return UIDynamicItemCollisionBoundsType.Ellipse
        }
    }
    
    static func getInstance() -> BallView {
        let ball = BallView()
        return ball
    }
    
    static func getInstance(bgColor: UIColor) -> BallView {
        let ball = BallView.getInstance()
        ball.backgroundColor = bgColor
        return ball
    }
    
    convenience init() {
        self.init(frame: CGRectMake(0, 0, BALLW, BALLW))
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        let arrayCount = UInt32(BALL_COLOR_ARRAY.count)
        let colorIndex = arc4random() % arrayCount
        self.backgroundColor = BALL_COLOR_ARRAY[Int(colorIndex)]
        
        self.layer.cornerRadius = frame.size.width / 2.0
        self.clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
