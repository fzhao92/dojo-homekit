//
//  XMCLockViewController.swift
//  dojo-homekit
//
//  Created by Forrest Zhao on 10/27/16.
//  Copyright © 2016 David McGraw. All rights reserved.
//

import UIKit
import HomeKit

class XMCLockViewController: UIViewController, HMAccessoryDelegate {
    
    @IBOutlet weak var lockCurrentStateSwitch: UISwitch!
    @IBOutlet weak var lockTargetStateSwitch: UISwitch!
    @IBOutlet weak var unlockedImage: UIImageView!
    @IBOutlet weak var lockedImage: UIImageView!
    
    var lockImage: UIImageView!
    var lockCurrentStateValue: HMCharacteristicValueLockMechanismState?
    //  var lockTargetStateValue:  // --- Find type for this
    var accessory: HMAccessory?
    var lockService: HMService?
    var lockTargetState: HMCharacteristic?
    var lockCurrentState: HMCharacteristic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        unlockedImage.isHidden = true
        
        for service in accessory!.services {
            if service.serviceType == HMServiceTypeLockMechanism {
                lockService = service
            }
        }
        currentLockStatus()
        accessory?.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeLockCurrentState(_ sender: UISwitch) {
        if sender.isOn {
            lockTargetState?.writeValue(1, completionHandler: { (error) in
                if error != nil {
                    print("Error during attempt to update service")
                }
                else {
                    self.animatelock()
                    
                }
            })
        }
        else {
            lockTargetState?.writeValue(0, completionHandler: { (error) in
                if error != nil{
                    print("Error during attempt to update service")
                } else {
                    self.animateUnlock()
                }
            })
        }
    }
    
    
    func currentLockStatus() {
        for item in (lockService?.characteristics)!{
            let characteristic = item as HMCharacteristic
            if let metadata = characteristic.metadata as HMCharacteristicMetadata? {
                if metadata.manufacturerDescription == "Lock Target State" {
                    lockTargetState = characteristic
                }
            }
            if let metadata = characteristic.metadata as HMCharacteristicMetadata? {
                if metadata.manufacturerDescription == "Lock Current State" {
                    lockCurrentState = characteristic
                }
            }
        }
    }
    
    func animatelock() {
        
        UIView.animate(withDuration: 10, delay: 0, options: .curveEaseInOut, animations: {
            self.unlockedImage.isHidden = true
            self.lockedImage.isHidden = false
            }, completion: nil)
        
    }
    
    func animateUnlock() {
        
        UIView.animate(withDuration: 10, delay: 0, options: .curveEaseInOut, animations: {
            self.unlockedImage.isHidden = false
            self.lockedImage.isHidden = true
            }, completion: nil)
        
    }
    
}
