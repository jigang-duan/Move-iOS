//
//  ToDoListController.swift
//  Move App
//
//  Created by LX on 2017/3/8.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class ToDoListController: UITableViewController {
    @IBOutlet weak var titleTextFieldQutle: UITextField!
    @IBOutlet weak var remarkTextFieldQutlet: UITextField!
    @IBOutlet weak var beginTimeQutlet: UITextField!
    @IBOutlet weak var endTimeQutlet: UITextField!
   
    var datePickView: UIView?
    var datePicker: UIDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0)
        beginTimeQutlet.inputView = self.datepickerInput()
        endTimeQutlet.inputView = self.datepickerInput()
        
        
    }
    
    
    func datepickerInput() -> (UIView) {
        
        datePickView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 210))
        datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 180))
        datePicker?.locale = NSLocale(localeIdentifier: "en_GB") as Locale
        self.datePickView?.addSubview(self.datePicker!)
        return self.datePickView!
    }
    
}

extension ToDoListController: UITextFieldDelegate {
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.tag == 1 {
            self.beginTimeQutlet.text = timechangeString(date: (self.datePicker?.date)!)
            
        }else
        {
            self.endTimeQutlet.text = timechangeString(date: (self.datePicker?.date)!)

        }
       
    }
    
    private func timechangeString(date : Date) -> String!{
        let dformatter = DateFormatter()
        dformatter.dateFormat = "MM-dd-yyyy HH:mm"
        let dateStr = dformatter.string(from: date)
        return dateStr
    }
    
    private func stringchangeTime(dateString : String) -> Date{
        let dformatter = DateFormatter()
        dformatter.dateFormat = "MM-dd-yyyy HH:mm"
        return dformatter.date(from: dateString)!
        
    }
    
}
