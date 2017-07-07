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
    //internationalization
    @IBOutlet weak var todolistTitleItem: UINavigationItem!
    @IBOutlet weak var saveItemQutlet: UIBarButtonItem!

    @IBOutlet weak var titleTextFieldQutle: UITextField!
    @IBOutlet weak var remarkTextFieldQutlet: UITextField!
    @IBOutlet weak var beginLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var repeatLabel: UILabel!
    

    @IBOutlet weak var repeatCell: UITableViewCell!
    @IBOutlet weak var repeatStateQutlet: UILabel!
    
    
    @IBOutlet weak var beginTimeQutle: UIButton!
    @IBOutlet weak var endTimeQutle: UIButton!
    @IBOutlet weak var cancelQutle: UIButton!
    @IBOutlet weak var comfirmQutle: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var DatePickerView: UIView!

    @IBOutlet weak var back: UIButton!
    
    
    var beginTimeVariable = Variable(DateUtility.today18())
    var endTimeVariabel = Variable(DateUtility.today18half())
    
    var todo: NSDictionary?
    var todos: [NSDictionary?] = []
    var isSame : Bool?
    var isOldTodo: Bool?
    
    var disposeBag = DisposeBag()
    
    var repeatStateVariable = Variable("Never")
    
    //国际化
    private func internationalization()  {
            todolistTitleItem.title = R.string.localizable.id_todolist()
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
        self.isOldTodo = false
        back.isHidden = false
        tableView.contentInset = UIEdgeInsetsMake(-32, 0, 0, 0)
        
        if todo != nil{
            titleTextFieldQutle.text = todo?["topic"] as? String
            remarkTextFieldQutlet.text = todo?["content"] as? String
            
            beginTimeVariable.value = (todo?["start"] as? Date)!
            endTimeVariabel.value = (todo?["end"] as? Date)!
         
            repeatStateVariable.value = repeatcountInt(Intt: (todo?["repeat"] as? Int)!)
            self.isOldTodo = true
        }
        
        repeatStateVariable.asDriver().drive(repeatStateQutlet.rx.text).addDisposableTo(disposeBag)
        
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
    
    //xib连线
    @IBAction func backAction(_ sender: Any) {
            _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        
        let cell = tableView.cellForRow(at: indexPath)
        let vc = R.storyboard.account.repeatViewController()!
        if cell == repeatCell {
            print("test")
            vc.repeatBlock = { [weak self] repea in
                self?.repeatStateVariable.value = repea
            }
            vc.selectCell = repeatStateQutlet.text ?? R.string.localizable.id_never()
            self.navigationController?.show(vc, sender: nil)
        }
    }
    
    
}

//保存，网络请求todolist
extension ToDoListController {
    //alert
    
    fileprivate func alertSeting(message: String,preferredStyle: UIAlertControllerStyle)
    {
        let alertController = UIAlertController(title: R.string.localizable.id_warming(), message: message, preferredStyle: preferredStyle)
        let okActiojn = UIAlertAction(title: R.string.localizable.id_ok(), style: .default, handler: nil)
        alertController.addAction(okActiojn)
        self.saveItemQutlet.isEnabled = true
        self.present(alertController, animated: true)
    }
    
    //保存
    fileprivate func saveAction() {
        
        self.saveItemQutlet.isEnabled = false
        
        if self.beginTime == self.endTime{
            //缺弹框提示语
            self.alertSeting(message: "begin time not the same as end time", preferredStyle: .alert)
            
        } else if (self.beginTime) < Date()
        {
            
            self.alertSeting(message: "begin time later than the system time", preferredStyle: .alert)
            
        }else if ((self.titleTextFieldQutle.text?.characters.count)! > 20 || ((self.remarkTextFieldQutlet.text?.characters.count)! > 50)) {
            
            self.alertSeting(message: "The title should not exceed 20 bytes, remark can't more than 50 bytes", preferredStyle: .alert)
            
        }else if self.titleTextFieldQutle.text == "" {
            
            self.alertSeting(message: "The title and remark can't Null", preferredStyle: .alert)
            self.saveItemQutlet.isEnabled = true
            
        }else if (self.beginTime) > (self.endTime) {
            
            self.alertSeting(message: "Start time later than the end of time", preferredStyle: .alert)
            self.saveItemQutlet.isEnabled = true
            
            
        }else
        {
            
            let _  = isOldTodo! ? KidSettingsManager.shared.updateTodoList(KidSetting.Reminder.ToDo(topic: todo?["topic"] as? String, content: todo?["content"] as? String, start: (todo?["start"] as? Date)!, end: (todo?["end"] as? Date)!, repeatCount: repeatcount(name: repeatcountInt(Intt: (todo?["repeat"] as? Int)!))), new: KidSetting.Reminder.ToDo(topic: titleTextFieldQutle.text, content: remarkTextFieldQutlet.text, start: beginTimeVariable.value, end: endTimeVariabel.value, repeatCount: repeatcount(name: self.repeatStateVariable.value))).subscribe(onNext:
            { [weak self] in
                print($0)
                if $0 {
                    let _ = self?.navigationController?.popViewController(animated: true)
                }else{
                    print("网络错误重新")
                    self?.saveItemQutlet.isEnabled = true
                }
            }).addDisposableTo(self.disposeBag)
                
                
                :
                KidSettingsManager.shared.creadTodoLis(KidSetting.Reminder.ToDo(topic: self.titleTextFieldQutle.text ?? "", content: self.remarkTextFieldQutlet.text ?? "", start: beginTime, end: endTime, repeatCount: repeatcount(name: self.repeatStateVariable.value))).subscribe(onNext:
                    { [weak self] in
                        print($0)
                        if $0 {
                            let _ = self?.navigationController?.popViewController(animated: true)
                        }else{
                            print("网络错误重新")
                            self?.saveItemQutlet.isEnabled = true
                        }
                }).addDisposableTo(self.disposeBag)
            
            
        }
        
    }
}

extension ToDoListController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      if textField == titleTextFieldQutle
      {
        remarkTextFieldQutlet.becomeFirstResponder()
        }else
      {
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
        if UIScreen.main.bounds.height < self.DatePickerView.frame.maxY{
            self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.size.height), animated: true)
        }else
        {
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
        if UIScreen.main.bounds.height < self.DatePickerView.frame.maxY{
            self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.size.height), animated: true)}
        else
        {
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
            if DateUtility.getDay(date: beginTimeVariable.value as NSDate) != DateUtility.getDay(date: endTimeVariabel.value as NSDate){
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

//repeat转换
extension ToDoListController {
    
   fileprivate func repeatcount(name: String) -> Int {
        
        return [R.string.localizable.id_never():0, R.string.localizable.id_week_everyday():1, R.string.localizable.id_everyweek() : 2, R.string.localizable.id_everymonth():3][name] ?? 0
        
    }
   fileprivate func repeatcountInt(Intt: Int) -> String {
        
        let InttString = String(Intt)
        return ["0": R.string.localizable.id_never(),"1": R.string.localizable.id_week_everyday(),"2": R.string.localizable.id_everyweek(),"3": R.string.localizable.id_everymonth() ][InttString]!
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

//rx
extension ToDoListController {
    
    //        let viewModel = ToDoListViewModel(
    //            input: (
    //                save: saveQutlet.rx.tap.asDriver(),
    //                topic: titleTextFieldQutle.rx.text.orEmpty.asDriver(),
    //                content: remarkTextFieldQutlet.rx.text.orEmpty.asDriver(),
    //                startime: beginTimeVariable.asDriver(),
    //                endtime: endTimeVariabel.asDriver(),
    //                repeatcount: repeatStateVariable.asDriver().map(repeatcount).debug()
    //            ),
    //            dependency: (
    //                kidSettingsManager: KidSettingsManager.shared,
    //                validation: DefaultValidation.shared,
    //                wireframe: DefaultWireframe.sharedInstance))
    //
    //        viewModel.saveFinish
    //            .drive(onNext: {[weak self] finish in
    //
    //                if self?.beginTime == self?.endTime{
    //                    let alertController = UIAlertController(title: R.string.localizable.warming(), message: "begin time not the same as end time", preferredStyle: .alert)
    //                    let okActiojn = UIAlertAction(title: "OK", style: .default, handler: nil)
    //                    alertController.addAction(okActiojn)
    //                    self?.present(alertController, animated: true)
    //
    //                } else if (self?.beginTime)! < Date()
    //                {
    //                    let alertController = UIAlertController(title: R.string.localizable.warming(), message: "begin time later than the system time", preferredStyle: .alert)
    //                    let okActiojn = UIAlertAction(title: "OK", style: .default, handler: nil)
    //                    alertController.addAction(okActiojn)
    //                    self?.present(alertController, animated: true)
    //                }else if ((self?.titleTextFieldQutle.text?.characters.count)! > 20 || ((self?.remarkTextFieldQutlet.text?.characters.count)! > 50)) {
    //                    let alertController = UIAlertController(title: R.string.localizable.warming(), message: "The title should not exceed 20 bytes, remark can't more than 50 bytes", preferredStyle: .alert)
    //                    let okActiojn = UIAlertAction(title: "OK", style: .default, handler: nil)
    //                    alertController.addAction(okActiojn)
    //                    self?.present(alertController, animated: true)
    //                }else if self?.titleTextFieldQutle.text == "" || self?.remarkTextFieldQutlet.text == ""{
    //                    let alertController = UIAlertController(title: R.string.localizable.warming(), message: "The title and remark can't Null", preferredStyle: .alert)
    //                    let okActiojn = UIAlertAction(title: "OK", style: .default, handler: nil)
    //                    alertController.addAction(okActiojn)
    //                    self?.present(alertController, animated: true)
    //                }else if (self?.beginTime)! > (self?.endTime)! {
    //                    let alertController = UIAlertController(title: R.string.localizable.warming(), message: "Start time later than the end of time", preferredStyle: .alert)
    //                    let okActiojn = UIAlertAction(title: "OK", style: .default, handler: nil)
    //                    alertController.addAction(okActiojn)
    //                    self?.present(alertController, animated: true)
    //
    //                }
    //                else if finish {
    //                    let _ = self?.navigationController?.popViewController(animated: true)
    //                }
    //
    //
    //            })
    //            .addDisposableTo(disposeBag)
    //
    //        viewModel.activityIn
    //            .map({ !$0 })
    //            .drive(saveQutlet.rx.isEnabled)
    //            .addDisposableTo(disposeBag)
    
    
    
}
