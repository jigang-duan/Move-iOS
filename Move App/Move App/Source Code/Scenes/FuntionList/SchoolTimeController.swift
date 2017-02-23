//
//  SchoolTimeController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/22.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class SchoolTimeController: UIViewController {
    
    @IBOutlet weak var OpenSchoolSwitch: UIButton!
    
    @IBOutlet weak var DatePickView: UIView!
    @IBOutlet weak var Datepicke: UIDatePicker!
    @IBOutlet weak var timeAmBtn1: UIButton!
    @IBOutlet weak var timeAmBtn2: UIButton!
    @IBOutlet weak var timePmBtn1: UIButton!
    @IBOutlet weak var timePmBtn2: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

}
    
    @IBAction func timeAmAction1(_ sender: UIButton) {
        sender.isEnabled = false
        timeAmBtn2.isEnabled = true
        timePmBtn1.isEnabled = true
        timePmBtn2.isEnabled = true
        
        DatePickView.isHidden = false
    }
    @IBAction func timeAmAction2(_ sender: UIButton) {
        sender.isEnabled = false
        timeAmBtn1.isEnabled = true
        timePmBtn1.isEnabled = true
        timePmBtn2.isEnabled = true
        
        DatePickView.isHidden = false
    }
    
    @IBAction func timePmAction1(_ sender: UIButton) {
        sender.isEnabled = false
        timeAmBtn2.isEnabled = true
        timeAmBtn1.isEnabled = true
        timePmBtn2.isEnabled = true
        
        DatePickView.isHidden = false
        
    }
    @IBAction func timePmAction2(_ sender: UIButton) {
        sender.isEnabled = false
        timeAmBtn2.isEnabled = true
        timeAmBtn1.isEnabled = true
        timePmBtn1.isEnabled = true
        
        DatePickView.isHidden = false
    }
    @IBAction func DatepickerCacel(_ sender: AnyObject) {
        DatePickView.isHidden = true
        timeAmBtn2.isEnabled = true
        timeAmBtn1.isEnabled = true
        timePmBtn1.isEnabled = true
        
    }
    @IBAction func DatepickerComfirm(_ sender: AnyObject) {
        if !timeAmBtn1.isEnabled {
            timeAmBtn1.setTitle(self.showPickerTime(), for: UIControlState.normal)
            timeAmBtn1.isEnabled = true
        }
        if !timeAmBtn2.isEnabled {
            timeAmBtn2.setTitle(self.showPickerTime(), for: UIControlState.normal)
            timeAmBtn2.isEnabled = true
        }
        if !timePmBtn1.isEnabled {
            timePmBtn1.setTitle(self.showPickerTime(), for: UIControlState.normal)
            timePmBtn1.isEnabled = true
        }
        if !timePmBtn2.isEnabled {
            timePmBtn2.setTitle(self.showPickerTime(), for: UIControlState.normal)
            timePmBtn2.isEnabled = true
        }
        
        
        DatePickView.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        DatePickView.isHidden = true
        timeAmBtn2.isEnabled = true
        timeAmBtn1.isEnabled = true
        timePmBtn1.isEnabled = true
        timePmBtn2.isEnabled = true
    }
    @IBAction func SchooltimeSwitch(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    
    @IBAction func WeekAction(_ sender: UIButton) {
        
        
        sender.isSelected = !sender.isSelected
        
        if !sender.isSelected {
            sender.backgroundColor = R.color.appColor.primary()
        }else
        {
            sender.backgroundColor = R.color.appColor.fourthlyText()
        }
        
    }
    
    
    
   private func showPickerTime() -> String {
        let date = Datepicke.date
        let dformatter = DateFormatter()
        dformatter.dateFormat = "HH:mm"
        let dateStr = dformatter.string(from: date)
    
        return dateStr
    }

}
