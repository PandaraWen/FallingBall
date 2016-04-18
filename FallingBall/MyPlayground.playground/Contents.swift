//: Playground - noun: a place where people can play

import UIKit

class Car : NSObject {
    func drive(para1: NSDictionary, para2: NSDictionary, didGetPara3 para3: NSDictionary) {
        
    }
}

let car = Car()
if car.respondsToSelector("drive:para2:didGetPara3:") {
    print("response")
}
