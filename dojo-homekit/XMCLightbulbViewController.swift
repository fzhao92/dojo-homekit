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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for service in accessory!.services {
            if service.serviceType == HMServiceTypeLightbulb {
                lightBulbService = service
            }
        }
        accessory?.delegate = self
    }
    
    @IBAction func lightSwitchTapped(_ sender: UISwitch) {
        
    }
}
