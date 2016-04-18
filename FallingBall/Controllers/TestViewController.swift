//
//  TestViewController.swift
//  FallingBall
//
//  Created by Pandara on 15/12/31.
//  Copyright © 2015年 Pandara. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()

        let centralButton = UIButton(type: UIButtonType.System)
        centralButton.setTitle("Central", forState: UIControlState.Normal)
        centralButton.addTarget(self, action: "pressCentralButton:", forControlEvents: UIControlEvents.TouchUpInside)
        centralButton.frame = CGRectMake((ScreenSize.width - 100) / 2.0, 50, 100, 100)
        self.view.addSubview(centralButton)
        
        let peripheralButton = UIButton(type: UIButtonType.System)
        peripheralButton.setTitle("Peripheral", forState: UIControlState.Normal)
        peripheralButton.addTarget(self, action: "perssPeripheralButton:", forControlEvents: UIControlEvents.TouchUpInside)
        peripheralButton.frame = CGRectMake((ScreenSize.width - 100) / 2.0, 200, 100, 100)
        self.view.addSubview(peripheralButton)
    }
    
    func pressCentralButton(button: UIButton) {
        let centralCon = CentralTestViewController()
        self.navigationController?.pushViewController(centralCon, animated: true)
    }
    
    func perssPeripheralButton(button: UIButton) {
        let peripheralCon = PeripheralTestViewController()
        self.navigationController?.pushViewController(peripheralCon, animated: true)
    }
}
