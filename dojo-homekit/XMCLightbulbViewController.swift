//
//  XMCLightbulbViewController.swift
//  dojo-homekit
//
//  Created by Forrest Zhao on 10/16/16.
//  Copyright © 2016 David McGraw. All rights reserved.
//

import UIKit
import HomeKit
import HandySwift

class XMCLightbulbViewController: UIViewController, HMAccessoryDelegate {

    @IBOutlet weak var lightBulb: UIView!
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
        checkLightState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for item in (lightBulbService?.characteristics)! {
            item.enableNotification(true, completionHandler: { (error) in
                if error != nil {
                    print("error enabling notificaiton")
                }
            })
        }
    }
}

extension XMCLightbulbViewController{
    
    func setUpSliders() {
        lightBrightnessSlider.maximumValue = 100.0
        lightBrightnessSlider.minimumValue = 0.0
        lightHueSlider.maximumValue = 360.0
        lightHueSlider.minimumValue = 0.0
        lightSaturationSlider.maximumValue = 100.0
        lightSaturationSlider.minimumValue = 0.0
    }

    @IBAction func moveBrightnessSlider(_ sender: UISlider) {
        let brightnessValue = sender.value
        brightness?.writeValue(Int(brightnessValue), completionHandler: { (error) in
            if error != nil {
                print("Error during attempt to update service")
            }
            else {
                self.updateBrightness(value: brightnessValue)
            }
        })
    }
    
    @IBAction func moveHueSlider(_ sender: UISlider) {
        let hueValue = sender.value
        hue?.writeValue(Int(hueValue), completionHandler: { (error) in
            if error != nil {
                print("Error during attempt to update service")
            }
            else {
                self.updateHue(value: hueValue)
            }
        })
    }
    
    @IBAction func moveSaturationSlider(_ sender: UISlider) {
        let saturationValue = sender.value
        //print("saturation value is \(saturationValue)")
        saturation?.writeValue(Int(saturationValue), completionHandler: { (error) in
            if error != nil {
                print("Error during attempt to update service")
            }
            else {
                self.updateSaturation(value: saturationValue)
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
    
    func checkLightState() {
        guard let stateValue = state?.value else {
            print("No current lightbulb state value available")
            return
        }
        if stateValue as! Bool != true {
            lightBulb.isHidden = true
            lightSwitch.isOn = false
        }
        else{
            lightBulb.isHidden = false
            lightSwitch.isOn = true
        }
    }
    
    func updateBrightness(value: Float) {
        lightBulb.alpha = CGFloat(value / maxBrightnessValue)
    }
    
    func updateHue(value: Float) {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        lightBulb.backgroundColor?.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        lightBulb.backgroundColor = UIColor(hue: CGFloat(value), saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    func updateSaturation(value: Float) {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        lightBulb.backgroundColor?.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        lightBulb.backgroundColor = UIColor(hue: hue, saturation: CGFloat(value), brightness: brightness, alpha: alpha)
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
        
    }
}

extension XMCLightbulbViewController {
    
    @objc(accessory:service:didUpdateValueForCharacteristic:) func accessory(_ accessory: HMAccessory, service: HMService, didUpdateValueFor characteristic: HMCharacteristic) {
        print("delegate triggered")
        for item in service.characteristics {
            let characteristic = item as HMCharacteristic
            if let metadata = characteristic.metadata! as HMCharacteristicMetadata? {
                switch metadata.manufacturerDescription! {
                case "Power State":
                    print("in power state switch statement")
                    characteristic.readValue(completionHandler: { (error) in
                        if error != nil {
                            print("Error reading value " + (error?.localizedDescription)!)
                        }
                        else {
                            let value = characteristic.value
                            print(value)
                        }
                    })
                default:
                    break
                }
            }
        }
    }
    /*
    @objc(accessory:didUpdateAssociatedServiceTypeForService:) func accessory(_ accessory: HMAccessory, didUpdateAssociatedServiceTypeFor service: HMService) {
        if service.serviceType == HMServiceTypeLightbulb {
            print("In light bulb delegate")
            for item in service.characteristics {
                let characteristic = item as HMCharacteristic
                if let metadata = characteristic.metadata! as HMCharacteristicMetadata? {
                    switch metadata.manufacturerDescription! {
                    case "Power State":
                        characteristic.readValue(completionHandler: { (error) in
                            if error != nil {
                                print("Error reading value " + (error?.localizedDescription)!)
                            }
                        })
                        checkLightState()
                    default:
                        break
                    }
                }
            }
        }
    }*/
}
