//
//  PeripheralTestViewController.swift
//  FallingBall
//
//  Created by Pandara on 16/1/5.
//  Copyright © 2016年 Pandara. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralTestViewController: UIViewController, FBCBPeripheralManagerDelegate {
    var canSendData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FBCBPeripheralManager.sharedManager.delegate = self
        self.view.backgroundColor = UIColor.whiteColor()
        
        let button = UIButton(type: UIButtonType.System)
        button.setTitle("send data", forState: UIControlState.Normal)
        button.frame = CGRectMake(0, 0, 100, 100)
        button.center = CGPointMake(ScreenSize.width / 2.0, ScreenSize.height / 2.0)
        button.addTarget(self, action: "pressButton:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
    }

    func pressButton(button: UIButton) {
        if !self.canSendData {
            return
        }
        
        let testDict = ["key1": "value1", "key2": "value2"]
        FBCBPeripheralManager.sharedManager.sendData(testDict)
    }
    
    // MARK: - FBCBPeripheralManagerDelegate
    func peripheralManagerDidUpdateState(peripheralManager: FBCBPeripheralManager) {
        if peripheralManager.state == .PoweredOn {
            FBCBPeripheralManager.sharedManager.startAdvertising()
        }
    }
    
    func peripheralManager(peripheral: FBCBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        canSendData = true
        NSLog("can send ble data now".green)
    }
}
