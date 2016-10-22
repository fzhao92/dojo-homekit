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
    
    var maxBrightnessValue: Float = 100.0
    var minBrightnessValue: Float = 0.0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        for service in accessory!.services {
            if service.serviceType == HMServiceTypeLightbulb {
                lightBulbService = service
            }
        }
        accessory?.delegate = self
        initCharacteristics()
        setUpSliders()
        checkInitialLightState()
    }
}

extension XMCLightbulbViewController{
    
    func setUpSliders() {
        lightBrightnessSlider.maximumValue = 100.0
        lightBrightnessSlider.minimumValue = 0.0
    }

    @IBAction func moveBrightnessSlider(_ sender: UISlider) {
        let brightnessValue = sender.value
        brightness?.writeValue(Int(brightnessValue), completionHandler: { (error) in
            if error != nil {
                print("Error during attempt to update service")
            }
            else {
                print("Current brightness is \(self.brightness?.value as! Int)")
                self.updateBrightness(value: brightnessValue)
            }
        })
    }
    
    @IBAction func lightSwitchTapped(_ sender: UISwitch) {
        guard let stateValue = state?.value else {
            print("No current lightbulb state value available")
            return
        }
        let toggleState = (stateValue as! Bool) ? false : true
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
        guard let stateValue = state?.value else {
            print("No current lightbulb state value available")
            return
        }
        if stateValue as! Bool != true {
            lightBulbColor.isHidden = true
            lightSwitch.isOn = true
        }
        else{
            lightBulbColor.isHidden = false
            lightSwitch.isOn = false
        }
    }
    
    func checkLightState() {
        guard let stateValue = state?.value else {
            print("No current lightbulb state value available")
            return
        }
        if stateValue as! Bool != true {
            lightBulbColor.isHidden = true
            lightSwitch.isOn = false
        }
        else{
            lightBulbColor.isHidden = false
            lightSwitch.isOn = true
        }
    }
    
    func updateBrightness(value: Float) {
        print("max brightness value is \(maxBrightnessValue)")
        lightBulbColor.alpha = CGFloat(value / maxBrightnessValue)
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
    
    func accessoryDidUpdateServices(_ accessory: HMAccessory) {
        <#code#>
    }
}
