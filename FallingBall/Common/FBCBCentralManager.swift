//
//  FBCBCentralManager.swift
//  FallingBall
//
//  Created by Pandara on 15/12/31.
//  Copyright © 2015年 Pandara. All rights reserved.
//

import Foundation
import CoreBluetooth
import RainbowSwift

@objc protocol FBCBCentralManagerDelegate : NSObjectProtocol {
    optional func centralManagerDidUpdateState(centralManager: FBCBCentralManager)
    optional func centralManager(centralManager: FBCBCentralManager, didReceiveDataDict dataDict: NSDictionary?)
    optional func centralManager(centralManager: FBCBCentralManager, connectedPeripheral peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?)
}

class FBCBCentralManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    let debugMode = true
    
    // MARK: - Property
    static let sharedManager = FBCBCentralManager()
    var central: CBCentralManager!
    var btUsable: Bool = false
    var discoveredPeripheral: CBPeripheral?
    var data = NSMutableData()
    
    weak var delegate: FBCBCentralManagerDelegate?
    
    var state: CBCentralManagerState {
        get {
            return self.central.state
        }
    }
    
    // MARK: - Method
    private override init() {
        super.init()
        self.central = CBCentralManager(delegate: self, queue: nil)
        
        cbLog("init central manager")
    }
    
    func scan() {
        if !btUsable {
            return
        }
        
        self.central.scanForPeripheralsWithServices([CBUUID(string: CB_SERVICE_UUID)], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    
    func stopAllWork() {
        self.cleanup()
    }
    
    private func cleanup() {
        
        if self.discoveredPeripheral?.state != CBPeripheralState.Connected {
            return
        }
        
        if let services = self.discoveredPeripheral?.services {
            for service in services {
                if let characteristics = service.characteristics {
                    for characteristic in characteristics {
                        if characteristic.UUID.isEqual(CB_CHARACTERISTIC_UUID) {
                            self.discoveredPeripheral?.setNotifyValue(false, forCharacteristic: characteristic)
                            return
                        }
                    }
                }
            }
        }
        
        self.central.cancelPeripheralConnection(self.discoveredPeripheral!)
    }
    
    private func cbLog(string: String) {
        if self.debugMode {
            NSLog(string)
        }
    }
    
    func cancelPeripheralConnection(peripheral: CBPeripheral) {
        self.central.cancelPeripheralConnection(peripheral)
    }
    
    // MARK: - CBCentralManagerDelegate
    // 扫描->发现设备->连接设备->发现服务->发现特征->订阅特征->取数据
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state == .PoweredOn {
            self.btUsable = true
        } else {
            self.btUsable = false
            cbLog("蓝牙不可用".red)
        }
        
        if let selector = self.delegate?.centralManagerDidUpdateState {
            selector(self)
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        cbLog("discover peripheral \(peripheral)")
        
        if self.discoveredPeripheral != peripheral {
            self.discoveredPeripheral = peripheral
            
            self.central.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        cbLog("failed to connect to \(peripheral), error: \(error?.localizedDescription)".red)
        self.cleanup()
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        cbLog("connected to peripheral".green)
        
        self.central.stopScan()
        cbLog("stop scan")
        
        self.data.length = 0//清空数据
        
        peripheral.delegate = self
        
        peripheral.discoverServices([CBUUID(string: CB_SERVICE_UUID)])
    }
    
    //如果连接断开，则清空本地 copy
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        cbLog("peripheral disconnected")
        self.discoveredPeripheral = nil
        
        self.scan()
    }
    
    // MARK: - CBPeripheralDelegate
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if let someError = error {
            cbLog("error discovering services: \(someError.localizedDescription)".red)
            self.cleanup()
            return
        }
        
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics([CBUUID(string: CB_CHARACTERISTIC_UUID)], forService: service)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if let someError = error {
            cbLog("error discovering characteristics: \(someError.localizedDescription)".red)
            self.cleanup()
            return
        }
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.UUID.UUIDString.isEqual(CB_CHARACTERISTIC_UUID) {
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                    cbLog("set notify to characteristic".blue)
                }
            }
        }
    }
    
    //如果特征有数据传输，我们会在这里得到
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let someError = error {
            cbLog("error updateing for characteristic: \(someError.localizedDescription)".red)
            return
        }
        
        if let characteristicValue = characteristic.value {
            let stringFromData = NSString(data: characteristicValue, encoding: NSUTF8StringEncoding)
            
            if stringFromData?.isEqualToString(EOM) == true {

                let unarchiver = NSKeyedUnarchiver(forReadingWithData: self.data)
                let decodeObj = unarchiver.decodeObject()
                unarchiver.finishDecoding()
                cbLog("receive totalmessage: \(decodeObj)".green)
                
                if let dict = decodeObj as? NSDictionary {
                    if self.delegate != nil && self.delegate!.respondsToSelector("centralManager:didReceiveDataDict:") {
                        self.delegate!.centralManager!(self, didReceiveDataDict: dict as NSDictionary)
                    }
                } else {
                    cbLog("the obj received is not a dict".red)
                }
                
                //注释掉下面代码让连接保持不断开
//                peripheral.setNotifyValue(false, forCharacteristic: characteristic)
//                self.central.cancelPeripheralConnection(peripheral)
                //将数据清空以接受下次数据
                self.data.length = 0
            } else {
                self.data.appendData(characteristicValue)
            }
        } else {
            cbLog("received characteristic contains no data".yellow)
        }
    }
    
    //在这里可以知道我们是否 订阅/取消订阅 某个特征
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if self.delegate != nil && self.delegate!.respondsToSelector("centralManager:connectedPeripheral:didUpdateNotificationStateForCharacteristic:error:") {
            self.delegate!.centralManager!(self, connectedPeripheral: peripheral, didUpdateNotificationStateForCharacteristic: characteristic, error: error)
        }
    }
}


































