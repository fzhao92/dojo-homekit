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
                    print("error enabling  \(item.metadata?.manufacturerDescription) notificaiton")
                }
            })
        }
    }
}

extension XMCLightbulbViewController{
    
    // MARK: - Initial setup
    
    func setUpSliders() {
        lightBrightnessSlider.maximumValue = 100.0
        lightBrightnessSlider.minimumValue = 0.0
        lightHueSlider.maximumValue = 360.0
        lightHueSlider.minimumValue = 0.0
        lightSaturationSlider.maximumValue = 100.0
        lightSaturationSlider.minimumValue = 0.0
        brightnessValueLabel.text = String(Int(lightBrightnessSlider.value))
        hueValueLabel.text = String(Int(lightHueSlider.value))
        saturationValueLabel.text = String(Int(lightSaturationSlider.value))
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
    
    // MARK: - switch and sliders funcs

    @IBAction func moveBrightnessSlider(_ sender: UISlider) {
        let brightnessValue = sender.value
        brightness?.writeValue(Int(brightnessValue), completionHandler: { (error) in
            if error != nil {
                print("Error during attempt to update brightness service")
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
                print("Error during attempt to update hue service")
            }
            else {
                self.hue?.readValue(completionHandler: { (error) in
                    if error != nil {
                        print("error reading hue value")
                    }
                    else {
                        let newHueVal = self.hue?.value as! Float
                        self.updateHue(value: newHueVal)
                    }
                })
            }
        })
    }
 
    @IBAction func moveSaturationSlider(_ sender: UISlider) {
        let saturationValue = sender.value
        saturation?.writeValue(Int(saturationValue), completionHandler: { (error) in
            if error != nil {
                print("Error during attempt to update saturation service")
            }
            else {
                self.saturation?.readValue(completionHandler: { (error) in
                    if error != nil {
                        print("error reading saturation value")
                    }
                    else {
                        let newSaturationVal = self.saturation?.value as! Float
                        self.updateSaturation(value: newSaturationVal)
                    }
                })
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
                print("Error during attempt to update state service")
            }
            else {
                self.state?.readValue(completionHandler: { (error) in
                    if error != nil {
                        print("error reading value")
                    }
                    else {
                        self.checkLightState(value: self.state?.value as! Bool)
                    }
                })
            }
        })
    }
    
    // MARK: - update lightbulb state properties
    
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
    
    func checkLightState(value: Bool) {
        if value != true {
            lightBulb.isHidden = true
            lightSwitch.isOn = false
        }
        else{
            lightBulb.isHidden = false
            lightSwitch.isOn = true
        }
    }
    
    func updateBrightness(value: Float) {
        lightBrightnessSlider.value = value
        brightnessValueLabel.text = String(Int(value))
        lightBulb.alpha = CGFloat(value / lightBrightnessSlider.maximumValue)
    }
    
    func updateHue(value: Float) {
        hueValueLabel.text = String(Int(value))
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        lightBulb.backgroundColor?.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        lightBulb.backgroundColor = UIColor(hue: CGFloat(value / lightHueSlider.maximumValue), saturation: saturation, brightness: brightness, alpha: alpha)
        self.lightHueSlider.value = value
    }
    
    func updateSaturation(value: Float) {
        lightSaturationSlider.value = value
        saturationValueLabel.text = String(Int(value))
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        lightBulb.backgroundColor?.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        lightBulb.backgroundColor = UIColor(hue: hue, saturation: CGFloat(value / lightSaturationSlider.maximumValue), brightness: brightness, alpha: alpha)
    }
    
}

// MARK: - HMAccessory Delegate methods

extension XMCLightbulbViewController {
    
    @objc(accessory:service:didUpdateValueForCharacteristic:) func accessory(_ accessory: HMAccessory, service: HMService, didUpdateValueFor characteristic: HMCharacteristic) {
        for item in service.characteristics {
            let characteristic = item as HMCharacteristic
            if let metadata = characteristic.metadata! as HMCharacteristicMetadata? {
                switch metadata.manufacturerDescription! {
                case "Power State":
                    characteristic.readValue(completionHandler: { (error) in
                        if error != nil {
                            print("Error reading power state value " + (error?.localizedDescription)!)
                        }
                        else {
                            let value = characteristic.value as! Bool
                            self.checkLightState(value: value)
                        }
                    })
                case "Hue":
                    characteristic.readValue(completionHandler: { (error) in
                        if error != nil {
                            print("Error reading hue value " + (error?.localizedDescription)!)
                        }
                        else {
                            let value = characteristic.value as! Float
                            self.updateHue(value: value)
                        }
                    })
                case "Brightness":
                    characteristic.readValue(completionHandler: { (error) in
                        if error != nil {
                            print("Error reading hue value " + (error?.localizedDescription)!)
                        }
                        else {
                            let value = characteristic.value as! Float
                            self.updateBrightness(value: value)
                        }
                    })
                case "Saturation":
                    characteristic.readValue(completionHandler: { (error) in
                        if error != nil {
                            print("Error reading hue value " + (error?.localizedDescription)!)
                        }
                        else {
                            let value = characteristic.value as! Float
                            self.updateSaturation(value: value)
                        }
                    })
                default:
                    break
                }
            }
        }
    }
}
