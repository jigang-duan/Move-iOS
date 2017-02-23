//
//  ToDoListController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/20.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class ToDoListController: UIViewController {

    
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var timeBtn: UIButton!
    @IBOutlet weak var DatePicekerView: UIView!
    @IBOutlet weak var PickerView: UIDatePicker!
    
    
    @IBAction func WeekAction(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if !sender.isSelected {
            sender.backgroundColor = UIColor.blue
        }else
        {
            sender.backgroundColor = UIColor.lightGray
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func timeAction(_ sender: UIButton) {
        sender.isEnabled = false
        DatePicekerView.isHidden = false
        
    }
    @IBAction func CancelAction(_ sender: UIButton) {
        DatePicekerView.isHidden = true
        timeBtn.isEnabled = true
    }
    @IBAction func ComfirmAction(_ sender: UIButton) {
        timeBtn.setTitle(showPickerTime(), for: UIControlState.normal)
        timeBtn.isEnabled = true
        DatePicekerView.isHidden = true
    }
    
    private func showPickerTime() -> String {
        let date = PickerView.date
        let dformatter = DateFormatter()
        dformatter.dateFormat = "HH:mm"
        let dateStr = dformatter.string(from: date)
        
        return dateStr
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        DatePicekerView.isHidden = true
        timeBtn.isEnabled = true
    }
    
    
   

   
}
