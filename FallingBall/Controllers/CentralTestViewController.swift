//
//  CentralTestViewController.swift
//  FallingBall
//
//  Created by Pandara on 16/1/5.
//  Copyright © 2016年 Pandara. All rights reserved.
//

import UIKit

class CentralTestViewController: UIViewController, FBCBCentralManagerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        FBCBCentralManager.sharedManager.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - FBCBCentralManagerDelegate
    func centralManagerDidUpdateState(centralManager: FBCBCentralManager) {
        if centralManager.state == .PoweredOn {
            centralManager.scan()
        }
    }
    

}
