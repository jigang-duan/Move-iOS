//
//  SetYourBirthdayController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/16.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class SetYourBirthdayController: UIViewController {

    @IBOutlet weak var setBirthLab: UILabel!
    @IBOutlet weak var saveBun: UIButton!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    var selectedDate: Date?
    
    var birthdayBlock: ((Date) -> Void)?
    
    private func initializeI18N() {
        setBirthLab.text = R.string.localizable.id_set_your_birthday()
        saveBun.setTitle(R.string.localizable.id_save(), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initializeI18N()
        
        // Do any additional setup after loading the view.
        datePicker.minimumDate = Date(timeIntervalSince1970: -2209017600)
        datePicker.maximumDate = Date()
        if let d = selectedDate {
            datePicker.date = d > datePicker.minimumDate! ? d:datePicker.minimumDate!
        }
        
    }
    

    @IBAction func BackAction(_ sender: AnyObject?) {
        self.dismiss(animated: true, completion: nil)
    }
   

  
    @IBAction func saveAction(_ sender: UIButton) {
        if self.birthdayBlock != nil {
            self.birthdayBlock!(datePicker.date)
        }
        self.BackAction(nil)
    }

}
