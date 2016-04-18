//
//  FBCBPeripheralManager.swift
//  FallingBall
//
//  Created by Pandara on 15/12/31.
//  Copyright © 2015年 Pandara. All rights reserved.
//

import UIKit
import CoreBluetooth

@objc protocol FBCBPeripheralManagerDelegate : NSObjectProtocol {
    optional func peripheralManagerDidUpdateState(peripheralManager: FBCBPeripheralManager)
    optional func peripheralManager(peripheral: FBCBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic)
}

class FBCBPeripheralManager: NSObject, CBPeripheralManagerDelegate {
    let debugMode = true
    
    // MARK: - Property
    static let sharedManager = FBCBPeripheralManager()
    var peripheral : CBPeripheralManager!
    var bleUsable = false
    var characteristic : CBMutableCharacteristic!
    var dataToSend: NSData!
    var sendDataIndex = 0
    var sendingEOM = false
    
    weak var delegate: FBCBPeripheralManagerDelegate?
    
    var state: CBPeripheralManagerState {
        get {
            return self.peripheral.state
        }
    }
    
    // MARK: - Method
    private override init() {
        super.init()
        self.peripheral = CBPeripheralManager(delegate: self, queue: nil)
        cbLog("init peripheral")
    }
    
    func sendData(dataDict: NSDictionary) {
        if !self.bleUsable {
            return
        }
        
        let mutableData = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: mutableData)
        archiver.encodeObject(dataDict)
        archiver.finishEncoding()
        
        if let data = mutableData.copy() as? NSData {
            self.dataToSend = data
            self.sendDataIndex = 0
            
            self.sendData()
        } else {
            cbLog("some error occur at dataDict to be sent".red)
        }
    }

    private func cbLog(string: String) {
        if self.debugMode {
            NSLog(string)
        }
    }
    
    func stopAdvertising() {
        self.peripheral.stopAdvertising()
    }
    
    func startAdvertising() {
        if !self.bleUsable {
            return
        }
        
        self.peripheral.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: CB_SERVICE_UUID)]])
    }
    
    private func sendData() {

        //首先，检查我们是否需要发送结束标识 EOM
        
        if sendingEOM {
            //发送 EOM
            let eomSend = self.peripheral.updateValue(EOM.dataUsingEncoding(NSUTF8StringEncoding)!, forCharacteristic: self.characteristic, onSubscribedCentrals: nil)
            
            //是否发送了
            if eomSend {
                //发送，则标记为已发送
                sendingEOM = false
                cbLog("sent eom".green)
            }
            
            //如果发送 eom 失败，退出并等到下一次回调中再次发送
            return
        }

        //如果不需要发送 EOM, 就发送数据
        //是否有数据剩下需要发送
        if self.sendDataIndex >= self.dataToSend.length {
            //无数据剩下，则不做任何事，正常情况不会进入这个回调
            cbLog("无数据要发送哦".yellow)
            return
        }
        
        //有数据剩下，则发送它们，直到返回发送失败，或者发送完毕
        var didSend = true
        
        while didSend {
            //构造下个数据包

            //计算需要发送多少数据
            var amountToSend = self.dataToSend!.length - self.sendDataIndex

            //数据长度不可超过 20 个字节
            if (amountToSend > NOTIFY_MTU) {
                amountToSend = NOTIFY_MTU
            }

            //将需要发送的数据复制一份
            let chunk = NSData(bytes: self.dataToSend.bytes + self.sendDataIndex, length: amountToSend)

            //发送数据
            didSend = self.peripheral.updateValue(chunk, forCharacteristic: self.characteristic, onSubscribedCentrals: nil)

            //如果发送失败，跳出并等到下次回调
            if !didSend {
                return
            }
            
            let stringFromData = String(data: chunk, encoding: NSUTF8StringEncoding)
            cbLog("sent \(stringFromData)")
            
            //如果发送完成，更新数据索引
            self.sendDataIndex += amountToSend
            
            //是否为最后一个数据包
            if self.sendDataIndex >= self.dataToSend.length {
                //是最后一个，那么接下来就发送 EOM
                //设置这个标志是为了，如果发送失败的话，下次仍可以继续发送
                self.sendingEOM = true
                
                //发送它
                let eomSent = self.peripheral.updateValue(EOM.dataUsingEncoding(NSUTF8StringEncoding)!, forCharacteristic: self.characteristic, onSubscribedCentrals: nil)
                
                if eomSent {
                    //发送成功的话，我们就完成本次数据的发送了
                    self.sendingEOM = false
                    cbLog("sent eom".green)
                }
                
                return
            }
        }
    }
    
    // MARK: - CBPeripheralManagerDelegate
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheral.state == CBPeripheralManagerState.PoweredOn {
            self.bleUsable = true
            
            self.characteristic = CBMutableCharacteristic(
                type: CBUUID(string: CB_CHARACTERISTIC_UUID),
                properties: CBCharacteristicProperties.Notify,
                value: nil,
                permissions: CBAttributePermissions.Readable
            )

            let service = CBMutableService(type: CBUUID(string: CB_SERVICE_UUID), primary: true)
            service.characteristics = [self.characteristic!]
            self.peripheral.addService(service)
        } else {
            self.bleUsable = false
            cbLog("蓝牙不可用")
        }
        
        if self.delegate != nil && self.delegate!.respondsToSelector(#selector(FBCBPeripheralManagerDelegate.peripheralManagerDidUpdateState(_:))) {
            self.delegate!.peripheralManagerDidUpdateState!(self)
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        cbLog("central subscribe to peripheral".blue)
        
        if self.delegate != nil && self.delegate!.respondsToSelector(#selector(FBCBPeripheralManagerDelegate.peripheralManager(_:central:didSubscribeToCharacteristic:))) {
            self.delegate!.peripheralManager!(self, central: central, didSubscribeToCharacteristic: characteristic)
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic) {
        cbLog("central did unsubscribe to peripheral")
    }
    
    //在发送错误之后恢复过来
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager) {
        self.sendData()
    }
}




















