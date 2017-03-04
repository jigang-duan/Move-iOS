//
//  ToDoListController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/20.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import CustomViews
import RxSwift
import RxCocoa

class ToDoListController: UIViewController {

    @IBOutlet weak var datePickView: UIView!
    @IBOutlet weak var datepicke: UIDatePicker!
    @IBOutlet weak var cancelQutlet: UIButton!
    @IBOutlet weak var confirmQulet: UIButton!
    
   
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var eventTimeQutlet: UIButton!
    
    @IBOutlet weak var weekQutlet: WeekView!
    @IBOutlet weak var saveQutlet: UIBarButtonItem!
    
    var eventTimeVariable = Variable(DateUtility.zone12hour())
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.datepicke.timeZone = TimeZone(secondsFromGMT: 0)
        
        self.eventTimeQutlet.rx.tap
            .asDriver()
            .drive(onNext: selectEventTime)
            .addDisposableTo(disposeBag)
        
        self.cancelQutlet.rx.tap
            .asDriver()
            .drive(onNext:  cancelDatepicker)
            .addDisposableTo(disposeBag)
        
        self.confirmQulet.rx.tap
            .asDriver()
            .drive(onNext:  confirmDatepicker)
            .addDisposableTo(disposeBag)
        
        eventTimeVariable.asDriver()
            .drive(onNext: { date in
                self.EventTime = date
            })
            .addDisposableTo(disposeBag)
        
    }
    
    func confirmDatepicker() {
        
        self.eventTimeQutlet.isSelected = false
        self.titleTextField.isEnabled = true
        self.eventTimeVariable.value = datepicke.date
        self.datePickView.isHidden = true
        
    }
    
    func cancelDatepicker() -> () {
        datePickView.isHidden = true
        self.eventTimeQutlet.isSelected  = true
        self.titleTextField.isEnabled = true
        
    }
    
    func selectEventTime() {
        self.eventTimeQutlet.isSelected = true
        self.datePickView.isHidden = false
        self.datepicke.date = EventTime
        self.titleTextField.isEnabled = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        datePickView.isHidden = true
        self.eventTimeQutlet.isSelected = false
        self.view.endEditing(true)
    }
    

   

    fileprivate var EventTime: Date {
        get {
            return  DateUtility.zoneDayOfHMS(date: DateUtility.date(from: eventTimeQutlet.titleLabel?.text))
        }
        set(newValue) {
            eventTimeQutlet.setTitle(zoneDateString(form: newValue), for: .normal)
        }
    }
    
    private func zoneDateString(form date: Date) -> String {
        let dformatter = DateFormatter()
        dformatter.timeZone = TimeZone(secondsFromGMT: 0)
        dformatter.dateFormat = "HH:mm"
        let dateStr = dformatter.string(from: date)
        return dateStr
    }

}
