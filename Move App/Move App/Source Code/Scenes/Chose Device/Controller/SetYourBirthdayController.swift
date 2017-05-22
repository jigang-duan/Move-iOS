//
//  SetYourBirthdayController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/16.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class SetYourBirthdayController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    var selectedDate: Date?
    
    var birthdayBlock: ((Date) -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        datePicker.maximumDate = Date()
        if let d = selectedDate {
            datePicker.date = d
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
