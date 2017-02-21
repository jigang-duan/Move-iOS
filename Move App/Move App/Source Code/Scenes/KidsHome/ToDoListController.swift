//
//  ToDoListController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/20.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class ToDoListController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func WeekAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        
    }
    @IBOutlet weak var DatePickView: UIView!
    @IBOutlet var DateViewBottomConstrain: [NSLayoutConstraint]!
    
    @IBAction func comfimAction(_ sender: AnyObject) {
        print(DatePick.date)
        
    }
    @IBAction func CancelAction(_ sender: AnyObject) {
        DatePickView.isHidden = true
        
    }
    @IBOutlet weak var DatePick: UIDatePicker!
    
    @IBAction func timeChange(_ sender: AnyObject) {
        
        DatePickView.isHidden = false
        
    }
    

   
}
