//
//  RegularshutdownController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/23.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class RegularshutdownController: UIViewController {

    @IBOutlet weak var timeone: UIButton!
    @IBOutlet weak var timetwo: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func AutomaticPowerAction(_ sender: UIButton) {
        sender.isSelected  = !sender.isSelected
    }
    @IBOutlet weak var DatepickView: UIView!
    @IBOutlet weak var DatePick: UIDatePicker!
    
    @IBAction func timeoneAction(_ sender: UIButton) {
        sender.isEnabled = false
        timetwo.isEnabled = true
        
        DatepickView.isHidden = false
    }
    
    @IBAction func timetwoAction(_ sender: UIButton) {
        sender.isEnabled = false
        timeone.isEnabled = true
        
        DatepickView.isHidden = false
        
    }
    @IBAction func CancelAction(_ sender: AnyObject) {
        
        DatepickView.isHidden = false
    }
    @IBAction func Comfirm(_ sender: AnyObject) {
        
        if !timeone.isEnabled {
            timeone.setTitle(self.showPickerTime(), for: UIControlState.normal)
            timeone.isEnabled = true
        }
        if !timetwo.isEnabled {
            timetwo.setTitle(self.showPickerTime(), for: UIControlState.normal)
            timetwo.isEnabled = true
        }
        
        
        DatepickView.isHidden = true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        timeone.isEnabled = true
        timetwo.isEnabled = true
        DatepickView.isHidden = true
    }
    private func showPickerTime() -> String {
        let date = DatePick.date
        let dformatter = DateFormatter()
        dformatter.dateFormat = "HH:mm"
        let dateStr = dformatter.string(from: date)
        
        return dateStr
    }

    
}
