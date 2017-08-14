//
//  ToDoListController.swift
//  Move App
//
//  Created by LX on 2017/3/8.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ToDoListController: UITableViewController {
    
    @IBOutlet weak var saveItemQutlet: UIBarButtonItem!
    
    @IBOutlet weak var titleTextFieldQutle: UITextField!
    @IBOutlet weak var remarkTextFieldQutlet: UITextField!
    @IBOutlet weak var beginLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var repeatLabel: UILabel!
    
    
    @IBOutlet weak var repeatStateQutlet: UILabel!
    
    
    @IBOutlet weak var beginTimeQutle: UIButton!
    @IBOutlet weak var endTimeQutle: UIButton!
    @IBOutlet weak var cancelQutle: UIButton!
    @IBOutlet weak var comfirmQutle: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var DatePickerView: UIView!
    
    
    var beginTimeVariable = Variable(DateUtility.today18())
    var endTimeVariabel = Variable(DateUtility.today18half())
    
    var todo: KidSetting.Reminder.ToDo?
    
    var isForAdd = false
    
    var disposeBag = DisposeBag()
    
    var repeatStateVariable = Variable(RepeatCount.never)
    
    //国际化
    private func internationalization()  {
        self.title = R.string.localizable.id_reminder()
        saveItemQutlet.title = R.string.localizable.id_save()
        titleTextFieldQutle.placeholder = R.string.localizable.id_title()
        remarkTextFieldQutlet.placeholder = R.string.localizable.id_remarks()
        beginLabel.text = R.string.localizable.id_begin()
        endLabel.text = R.string.localizable.id_end()
        repeatLabel.text = R.string.localizable.id_setting_my_clock_repeat()
        cancelQutle.setTitle(R.string.localizable.id_cancel(), for: .normal)
        comfirmQutle.setTitle(R.string.localizable.id_confirm(), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        internationalization()
        
        tableView.contentInset = UIEdgeInsetsMake(-32, 0, 0, 0)
        
        if isForAdd == false {
            titleTextFieldQutle.text = todo?.topic
            remarkTextFieldQutlet.text = todo?.content
            
            if let start = todo?.start {
                beginTimeVariable.value = start
            }
            if let end = todo?.end {
                endTimeVariabel.value = end
            }
            
            repeatStateVariable.value = RepeatCount(rawValue: (todo?.repeatCount ?? 0))!
        }
        
        repeatStateVariable.asDriver()
            .drive(onNext: {[weak self] rc in
                self?.repeatStateQutlet.text = rc.description()
            })
            .addDisposableTo(disposeBag)
        
        beginTimeVariable.asDriver()
            .drive(onNext: {[weak self] date in
                self?.beginTime = date
            })
            .addDisposableTo(disposeBag)
        
        self.beginTimeQutle.rx.tap
            .asDriver()
            .drive(onNext: {[weak self] in
                self?.selectBeginTime()
            })
            .addDisposableTo(disposeBag)
        
        endTimeVariabel.asDriver()
            .drive(onNext: {[weak self] date in
                self?.endTime = date
            })
            .addDisposableTo(disposeBag)
        
        self.endTimeQutle.rx.tap
            .asDriver()
            .drive(onNext: {[weak self] in
                self?.selectEndTime()
            })
            .addDisposableTo(disposeBag)
        
        self.comfirmQutle.rx.tap
            .asDriver()
            .drive(onNext: {[weak self] in
                self?.comfirmDatepicker()
            })
            .addDisposableTo(disposeBag)
        
        self.cancelQutle.rx.tap
            .asDriver()
            .drive(onNext: {[weak self] in
                self?.cancelDatepicker()
            })
            .addDisposableTo(disposeBag)
        
        self.saveItemQutlet.rx.tap.asDriver().drive(onNext: {[weak self] in
            self?.saveAction()
        }).addDisposableTo(disposeBag)
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = R.segue.toDoListController.showRepeatTime(segue: segue)?.destination {
            vc.repeatBlock = { [weak self] repea in
                self?.repeatStateVariable.value = repea
            }
            vc.selectedRepeat = repeatStateVariable.value
        }
    }
    
    
}

//保存，网络请求todolist
extension ToDoListController {
    //alert
    
    fileprivate func alertSeting(message: String,preferredStyle: UIAlertControllerStyle)
    {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: preferredStyle)
        let okActiojn = UIAlertAction(title: R.string.localizable.id_ok(), style: .default, handler: nil)
        alertController.addAction(okActiojn)
        self.saveItemQutlet.isEnabled = true
        self.present(alertController, animated: true)
    }
    
    //保存
    fileprivate func saveAction() {
        if self.beginTime == self.endTime{
            self.alertSeting(message: R.string.localizable.id_begin_time_same_end(), preferredStyle: .alert)
            
        } else if (self.beginTime) < Date(){
            self.alertSeting(message: R.string.localizable.id_begin_time_later_system(), preferredStyle: .alert)
            
        }else if ((self.titleTextFieldQutle.text?.characters.count)! > 20 || ((self.remarkTextFieldQutlet.text?.characters.count)! > 50)) {
            self.alertSeting(message: R.string.localizable.id_reminder_remarks_characters() + " or " + R.string.localizable.id_reminder_title_characters(), preferredStyle: .alert)
            
        }else if self.titleTextFieldQutle.text == "" {
            self.alertSeting(message: R.string.localizable.id_title_can_not_null(), preferredStyle: .alert)
            self.saveItemQutlet.isEnabled = true
            
        }else if (self.beginTime) > (self.endTime) {
            self.alertSeting(message: R.string.localizable.id_end_less_than_start_time(), preferredStyle: .alert)
            self.saveItemQutlet.isEnabled = true
            
        }else{
            self.saveItemQutlet.isEnabled = false
            
            if isForAdd == true {
                KidSettingsManager.shared.addTodo(KidSetting.Reminder.ToDo(topic: self.titleTextFieldQutle.text ?? "", content: self.remarkTextFieldQutlet.text ?? "", start: beginTime, end: endTime, repeatCount:  self.repeatStateVariable.value.rawValue))
                    .subscribe(onNext:{ [weak self] in
                        if $0 {
                            let _ = self?.navigationController?.popViewController(animated: true)
                        }else{
                            self?.saveItemQutlet.isEnabled = true
                        }
                    })
                    .addDisposableTo(self.disposeBag)
            }else{
                KidSettingsManager.shared.updateTodoList(todo!, new: KidSetting.Reminder.ToDo(topic: titleTextFieldQutle.text, content: remarkTextFieldQutlet.text, start: beginTimeVariable.value, end: endTimeVariabel.value, repeatCount: self.repeatStateVariable.value.rawValue))
                    .subscribe(onNext:{ [weak self] in
                        if $0 {
                            let _ = self?.navigationController?.popViewController(animated: true)
                        }else{
                            self?.saveItemQutlet.isEnabled = true
                        }
                    })
                    .addDisposableTo(self.disposeBag)
            }
        }
        
    }
}

extension ToDoListController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextFieldQutle
        {
            remarkTextFieldQutlet.becomeFirstResponder()
        }else{
            view.endEditing(true)
        }
        
        return true
    }
}

//按钮监听事件
extension ToDoListController {
    
    fileprivate func selectBeginTime() {
        self.datePicker.datePickerMode = .dateAndTime
        self.datePicker.minimumDate = Date.today().startDate
        self.beginTimeQutle.isSelected = true
        self.endTimeQutle.isSelected = false
        self.datePicker.date = beginTime
        self.DatePickerView.isHidden = false
        if (UIScreen.main.bounds.height-64) < self.tableView.contentSize.height{
            self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.size.height), animated: true)
        }else{
            self.DatePickerView.frame.origin.y = 400
            print(DatePickerView.frame.origin.y)
        }
        view.endEditing(true)
        
    }
    
    fileprivate func selectEndTime() {
        self.datePicker.datePickerMode = .time
        self.datePicker.date = beginTime
        self.datePicker.minimumDate = beginTime
        self.endTimeQutle.isSelected = true
        self.beginTimeQutle.isSelected = false
        self.datePicker.date = endTime
        self.DatePickerView.isHidden = false
        if (UIScreen.main.bounds.height-64) < self.tableView.contentSize.height{
            self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.size.height), animated: true)}
        else{
            self.DatePickerView.frame.origin.y = 400
        }
        
        view.endEditing(true)
        
    }
    
    fileprivate func cancelDatepicker() {
        DatePickerView.isHidden = true
        beginTimeQutle.isSelected = false
        endTimeQutle.isSelected = false
        self.tableView.setContentOffset(CGPoint(x: 0, y: 32), animated: true)
        
    }
    
    fileprivate func comfirmDatepicker() {
        
        self.tableView.setContentOffset(CGPoint(x: 0, y: 32), animated: true)
        
        if beginTimeQutle.isSelected {
            beginTimeQutle.isSelected = false
            beginTimeVariable.value = datePicker.date
            if DateUtility.getDay(date: beginTimeVariable.value) != DateUtility.getDay(date: endTimeVariabel.value){
                endTimeVariabel.value = beginTimeVariable.value
            }
            
        }
        
        if endTimeQutle.isSelected {
            endTimeQutle.isSelected = false
            endTimeVariabel.value = datePicker.date
        }
        
        DatePickerView.isHidden = true
    }
    
    
}


//时间转换
extension ToDoListController {
    
    fileprivate func stringchangeTime(dateString : String) -> Date{
        let dformatter = DateFormatter()
        dformatter.dateFormat = "MM-dd-yyyy HH:mm"
        return (dformatter.date(from: dateString)) ?? Date()
        
    }
    
    fileprivate func DateString(form date: Date) -> String {
        let dformatter = DateFormatter()
        dformatter.dateFormat = "MM-dd-yyyy HH:mm"
        let dateStr = dformatter.string(from: date)
        return dateStr
    }
    
    
    
    fileprivate var beginTime: Date {
        get {
            return  stringchangeTime(dateString: (beginTimeQutle.titleLabel?.text)!)
        }
        set(newValue) {
            beginTimeQutle.setTitle(DateString(form: newValue), for: .normal)
            
        }
    }
    
    fileprivate var endTime: Date {
        get {
            return stringchangeTime(dateString: (endTimeQutle.titleLabel?.text)!)
        }
        set(newValue) {
            endTimeQutle.setTitle(DateString(form: newValue), for: .normal)
        }
    }
    
    
    
}


