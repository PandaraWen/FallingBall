//
//  CupViewController.swift
//  FallingBall
//
//  Created by Pandara on 15/12/30.
//  Copyright © 2015年 Pandara. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreMotion

class CupViewController: UIViewController, UICollisionBehaviorDelegate, FBCBCentralManagerDelegate, FBCBPeripheralManagerDelegate {
    let boundaryIDLeft = "left"
    let boundaryIDRight = "right"
    let boundaryIDBottom = "bottom"
    let boundaryIDTop = "top"
    
    var hasAddBall = false
    
    var animator: UIDynamicAnimator!
    var gravityBehavior: UIGravityBehavior!
    var ballBehavior: UIDynamicItemBehavior!
    var collisionBehavior: UICollisionBehavior!
    var ballArray = NSMutableArray()
    
    var coreMotionManager: CMMotionManager!
    
    var gyroTestLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.animator = UIDynamicAnimator(referenceView: self.view)

        self.gyroTestLabel = UILabel(frame: CGRectMake(0, 100, ScreenSize.width, 100))
        self.gyroTestLabel.numberOfLines = 0
        self.view.addSubview(self.gyroTestLabel)
        
        //Gravity
        self.setupGravity()
        
        //Collision
        self.setupCollision()
        
        //BallBehavior
        self.setupBallBehavior()
        
        //CoreMotion
        self.setupCoreMotion()
        
        let button = UIButton(type: UIButtonType.System)
        button.frame = CGRectMake((ScreenSize.width - 100) / 2.0, 0, 100, 100)
        button.addTarget(self, action: #selector(CupViewController.pressConnectButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
    }
    
    func setupGravity() {
        self.gravityBehavior = UIGravityBehavior()
        self.animator.addBehavior(self.gravityBehavior)
    }
    
    func setupCollision() {
        self.collisionBehavior = UICollisionBehavior()
        self.collisionBehavior.collisionDelegate = self
        
        let topY: CGFloat = -(BALLW + 10)
        
        self.collisionBehavior.addBoundaryWithIdentifier(boundaryIDLeft, fromPoint: CGPointMake(0, topY), toPoint: CGPointMake(0, ScreenSize.height))
        self.collisionBehavior.addBoundaryWithIdentifier(boundaryIDBottom, fromPoint: CGPointMake(0, ScreenSize.height), toPoint: CGPointMake(ScreenSize.width, ScreenSize.height))
        self.collisionBehavior.addBoundaryWithIdentifier(boundaryIDRight, fromPoint: CGPointMake(ScreenSize.width, ScreenSize.height), toPoint: CGPointMake(ScreenSize.width, topY))
        self.collisionBehavior.addBoundaryWithIdentifier(boundaryIDTop, fromPoint: CGPointMake(0, topY), toPoint: CGPointMake(ScreenSize.width, topY))
        self.collisionBehavior.collisionMode = UICollisionBehaviorMode.Everything
        self.animator.addBehavior(collisionBehavior)
    }
    
    func setupBallBehavior() {
        self.ballBehavior = UIDynamicItemBehavior()
        self.ballBehavior.elasticity = 0.75
        self.ballBehavior.allowsRotation = false
        self.animator.addBehavior(ballBehavior)
    }
    
    func setupCoreMotion() {
        self.coreMotionManager = CMMotionManager()
        
        let queue = NSOperationQueue()
        
        if self.coreMotionManager.deviceMotionAvailable {
            self.coreMotionManager.deviceMotionUpdateInterval = 0.1
            
            self.coreMotionManager.startDeviceMotionUpdatesToQueue(queue) { ( deviceMotion: CMDeviceMotion?, error: NSError?) -> Void in
                if let errorInner = error {
                    
                    self.coreMotionManager.stopDeviceMotionUpdates()
                    NSLog("coreMotion update device motion error: \(errorInner.localizedDescription)")
                    
                } else {
                    
                    if let deviceMotionInner = deviceMotion {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            var angle = acos(CGFloat(deviceMotionInner.gravity.x))
                            if deviceMotionInner.gravity.y > 0 {
                                angle *= -1
                            }
                            self.gravityBehavior.angle = angle
                        })
                        
                    } else {
                        NSLog("device motion is nil".red)
                    }
                    
                }
            }
        } else {
            NSLog("gravity unavailable".red)
        }
        
    }
    
    func addBalls() {
        //Balls
        for _ in 0..<1 {
            let ball = BallView.getInstance()
            ball.center = CGPointMake(ScreenSize.width / 2.0, ScreenSize.height / 2.0)
            self.view.addSubview(ball)
            self.ballArray.addObject(ball)
            
            let pushBehavior = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.Instantaneous)
            pushBehavior.magnitude = 1.5
            let angle = Double(Int(arc4random()) % 360) / Double(360) * (M_PI * 2)
            pushBehavior.angle = CGFloat(angle)
            self.animator.addBehavior(pushBehavior)
            
            self.gravityBehavior.addItem(ball)
            self.collisionBehavior.addItem(ball)
            self.ballBehavior.addItem(ball)
        }
    }
    
    func addBall(center: CGPoint, withBGColor bgColor: UIColor) {
        let ball = BallView.getInstance(bgColor)
        ball.center = center
        self.view.addSubview(ball)
        self.ballArray.addObject(ball)
        
        let pushBehavior = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.Instantaneous)
        pushBehavior.magnitude = 1.5
        pushBehavior.angle = CGFloat(M_PI / 2)
        self.animator.addBehavior(pushBehavior)
        
        self.gravityBehavior.addItem(ball)
        self.collisionBehavior.addItem(ball)
        self.ballBehavior.addItem(ball)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !self.hasAddBall {
            self.hasAddBall = true
            self.addBalls()
        }
    }
    
    func pressConnectButton(button: UIButton) {
        let con = ConnectViewController()
        self.presentViewController(con, animated: true, completion: nil)
    }
    
    // MARK: - UICollisionBehaviorDelegate
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        if let idStr = identifier as? NSString {
            if idStr.isEqualToString(boundaryIDTop) {
//                let ballModel = BallModel()
//                ballModel.center.x = Float(item.center.x)
//                ballModel.center.y = Float(item.center.y)
//                ballModel.velocity.value = item.
//                let velocity = self.ballBehavior.linearVelocityForItem(item)
                
                FBCBPeripheralManager.sharedManager.sendData([kBallDataX: NSNumber(double: Double(item.center.x)), kBallDataY: NSNumber(double: Double(item.center.y))])
                
                self.gravityBehavior.removeItem(item)
                self.collisionBehavior.removeItem(item)
                self.ballBehavior.addItem(item)
                self.ballArray.removeObject(item)
                (item as! BallView).removeFromSuperview()
            }
        }
    }
    
    // MARK: - FBCBCentralManagerDelegate
    func centralManager(centralManager: FBCBCentralManager, didReceiveDataDict dataDict: NSDictionary?) {
        NSLog("cupViewCon: receive data dict: \(dataDict)".green)
        
        if let ballData = dataDict {
            let x: Double = (ballData.objectForKey(kBallDataX)! as! NSNumber).doubleValue
            let y: Double = (ballData.objectForKey(kBallDataY)! as! NSNumber).doubleValue
            
            self.addBall(CGPointMake(CGFloat(x), CGFloat(y)), withBGColor: UIColor.blackColor())
        }
    }
    
    func centralManager(centralManager: FBCBCentralManager, connectedPeripheral peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let someError = error {
            NSLog("cupViewCon: error updateing notification state for characteristic: \(someError.localizedDescription)".red)
            return
        }
        
        if !characteristic.UUID.isEqual(CBUUID(string: CB_CHARACTERISTIC_UUID)) {
            return
        }
        
        if !characteristic.isNotifying {
            NSLog("cupViewCon: notification stopped on \(characteristic), disconnecting")
            FBCBCentralManager.sharedManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    // MARK: - FBCBPeripheralManagerDelegate
    
}













