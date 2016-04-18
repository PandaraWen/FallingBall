//
//  ConnectViewController.swift
//  FallingBall
//
//  Created by Pandara on 16/1/6.
//  Copyright © 2016年 Pandara. All rights reserved.
//

import UIKit
import CoreBluetooth
import SnapKit

class ConnectViewController: UIViewController, FBCBCentralManagerDelegate, FBCBPeripheralManagerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        let centralButton = UIButton(type: UIButtonType.System)
        centralButton.setTitle("Central", forState: UIControlState.Normal)
        centralButton.addTarget(self, action: #selector(ConnectViewController.pressCentralButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(centralButton)
        
        centralButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(100, 100))
            make.top.equalTo(self.view)
            make.centerX.equalTo(self.view)
        }
        
        let peripheralButton = UIButton(type: UIButtonType.System)
        peripheralButton.setTitle("Peripheral", forState: UIControlState.Normal)
        peripheralButton.addTarget(self, action: #selector(ConnectViewController.perssPeripheralButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(peripheralButton)
        
        peripheralButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(100, 100))
            make.top.equalTo(centralButton.snp_bottom)
            make.centerX.equalTo(self.view)
        }
        
        let closeButton = UIButton(type: UIButtonType.System)
        closeButton.setTitle("Close", forState: UIControlState.Normal)
        closeButton.addTarget(self, action: #selector(ConnectViewController.pressCloseButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        closeButton.frame = CGRectMake((ScreenSize.width - 100) / 2.0, 200, 100, 100)
        closeButton.addTarget(self, action: #selector(ConnectViewController.pressCloseButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(closeButton)
        
        closeButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(100, 100))
            make.top.equalTo(peripheralButton.snp_bottom)
            make.centerX.equalTo(self.view)
        }
    }
    
    func pressCentralButton(button: UIButton) {
        FBCBCentralManager.sharedManager.delegate = self
        FBExternalValueManager.shareManager.blueToothRole = FBBlueToothRole.Central
    }
    
    func perssPeripheralButton(button: UIButton) {
        FBCBPeripheralManager.sharedManager.delegate = self
        FBExternalValueManager.shareManager.blueToothRole = FBBlueToothRole.Peripheral
    }
    
    func pressCloseButton(button: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - FBCBCentralManagerDelegate
    func centralManagerDidUpdateState(centralManager: FBCBCentralManager) {
        if centralManager.state == .PoweredOn {
            centralManager.scan()
        }
    }
    
    func centralManager(centralManager: FBCBCentralManager, connectedPeripheral peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let someError = error {
            NSLog("error updateing notification state for characteristic: \(someError.localizedDescription)".red)
            return
        }
        
        if !characteristic.UUID.isEqual(CBUUID(string: CB_CHARACTERISTIC_UUID)) {
            return
        }
        
        if characteristic.isNotifying {
            NSLog("notification begin on \(characteristic)")
            FBCBCentralManager.sharedManager.delegate = FBToolKit.getCupViewCon()
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            NSLog("notification stopped on \(characteristic), disconnecting")
            FBCBCentralManager.sharedManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    // MARK: - FBCBPeripheralManagerDelegate
    func peripheralManagerDidUpdateState(peripheralManager: FBCBPeripheralManager) {
        if peripheralManager.state == .PoweredOn {
            FBCBPeripheralManager.sharedManager.startAdvertising()
        }
    }
    
    func peripheralManager(peripheral: FBCBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        FBCBPeripheralManager.sharedManager.delegate = FBToolKit.getCupViewCon()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}







