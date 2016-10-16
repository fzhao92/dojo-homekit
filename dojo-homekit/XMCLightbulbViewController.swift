//
//  XMCLightbulbViewController.swift
//  dojo-homekit
//
//  Created by Forrest Zhao on 10/16/16.
//  Copyright © 2016 David McGraw. All rights reserved.
//

import UIKit
import HomeKit

class XMCLightbulbViewController: UIViewController, HMAccessoryDelegate {

    @IBOutlet weak var lightBulbColor: UIView!
    @IBOutlet weak var lightSwitch: UISwitch!
    @IBOutlet weak var lightBrightnessSlider: UISlider!
    @IBOutlet weak var lightHueSlider: UISlider!
    @IBOutlet weak var lightSaturationSlider: UISlider!
    @IBOutlet weak var brightnessValueLabel: UILabel!
    @IBOutlet weak var hueValueLabel: UILabel!
    @IBOutlet weak var saturationValueLabel: UILabel!
    
    var hueValue: Float = 0.0
    var brightnessValue: Float = 0.0
    var saturationValue: Float = 0.0
    var accessory: HMAccessory?
    var lightBulbService: HMService?
    var state: HMCharacteristic?
    var hue: HMCharacteristic?
    var brightness: HMCharacteristic?
    var saturation: HMCharacteristic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for service in accessory!.services {
            if service.serviceType == HMServiceTypeLightbulb {
                lightBulbService = service
            }
        }
        accessory?.delegate = self
        initCharacteristics()
        checkInitialLightState()
        print("Current brightness is \(brightness?.value as! Float)")

    }
    
    @IBAction func lightSwitchTapped(_ sender: UISwitch) {
        let toggleState = (state?.value as! Bool) ? false : true
        state?.writeValue(NSNumber(value: toggleState ), completionHandler: { (error) -> Void in
            if error != nil {
                print("Error during attempt to update service")
            }
            else {
                self.checkLightState()
            }
        })
    }
    
    func checkInitialLightState() {
        if state?.value as! Bool == true {
            lightBulbColor.backgroundColor = UIColor.red.withAlphaComponent(1.0)
            lightSwitch.isOn = true
        }
        else{
            lightBulbColor.backgroundColor = UIColor.red.withAlphaComponent(0.5)
            lightSwitch.isOn = false
        }
    }
    
    func checkLightState() {
        if state?.value as! Bool == true {
            lightBulbColor.backgroundColor = UIColor.red.withAlphaComponent(1.0)
        }
        else{
            lightBulbColor.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        }
    }
    
    func initCharacteristics() {
        for item in (lightBulbService?.characteristics)! {
            let characteristic = item as HMCharacteristic
            if let metadata = characteristic.metadata as HMCharacteristicMetadata?{
                switch metadata.manufacturerDescription! {
                case "Power State":
                    state = characteristic
                case "Hue":
                    hue = characteristic
                case "Saturation":
                    saturation = characteristic
                case "Brightness":
                    brightness = characteristic
                default:
                    break
                }
            }
        }
    }
}
