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
    @IBOutlet weak var saveQutlet: UIButton!
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
    
    func internationalization()  {
            todolistTitleItem.title = R.string.localizable.todolist()
            saveQutlet.setTitle(R.string.localizable.save(), for: .normal)
            titleTextFieldQutle.placeholder = R.string.localizable.title()
            remarkTextFieldQutlet.placeholder = R.string.localizable.remarks()
            beginLabel.text = R.string.localizable.begin()
            endLabel.text = R.string.localizable.end()
            repeatLabel.text = R.string.localizable.repeat()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.internationalization()
        self.isOldTodo = false
        back.isHidden = false
        
        if todo != nil{
            titleTextFieldQutle.text = todo?["topic"] as? String
            remarkTextFieldQutlet.text = todo?["content"] as? String
            
            beginTimeVariable.value = (todo?["start"] as? Date)!
            endTimeVariabel.value = (todo?["end"] as? Date)!
         
            repeatStateVariable.value = repeatcountInt(Intt: (todo?["repeat"] as? Int)!)
            self.isOldTodo = true
        }
        
        tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0)
        repeatStateVariable.asDriver().drive(repeatStateQutlet.rx.text).addDisposableTo(disposeBag)
        
        
        beginTimeVariable.asDriver()
            .drive(onNext: {date in
                self.beginTime = date
            })
            .addDisposableTo(disposeBag)
        
        self.beginTimeQutle.rx.tap
            .asDriver()
            .drive(onNext: selectBeginTime)
            .addDisposableTo(disposeBag)
        
        endTimeVariabel.asDriver()
            .drive(onNext: {date in
                self.endTime = date
            })
            .addDisposableTo(disposeBag)

        self.endTimeQutle.rx.tap
            .asDriver()
            .drive(onNext: selectEndTime)
            .addDisposableTo(disposeBag)
        
        self.comfirmQutle.rx.tap
            .asDriver()
            .drive(onNext: comfirmDatepicker)
            .addDisposableTo(disposeBag)
        
        self.cancelQutle.rx.tap
            .asDriver()
            .drive(onNext: cancelDatepicker)
            .addDisposableTo(disposeBag)
        
        self.saveQutlet.rx.tap.asDriver().drive(onNext: saveAction).addDisposableTo(disposeBag)
        
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
    
    func saveAction() {
       
        
        if self.beginTime == self.endTime{
            let alertController = UIAlertController(title: R.string.localizable.warming(), message: "begin time not the same as end time", preferredStyle: .alert)
            let okActiojn = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okActiojn)
            self.present(alertController, animated: true)
            
        } else if (self.beginTime) < Date()
        {
            let alertController = UIAlertController(title: R.string.localizable.warming(), message: "begin time later than the system time", preferredStyle: .alert)
            let okActiojn = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okActiojn)
            self.present(alertController, animated: true)
        }else if ((self.titleTextFieldQutle.text?.characters.count)! > 20 || ((self.remarkTextFieldQutlet.text?.characters.count)! > 50)) {
            let alertController = UIAlertController(title: R.string.localizable.warming(), message: "The title should not exceed 20 bytes, remark can't more than 50 bytes", preferredStyle: .alert)
            let okActiojn = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okActiojn)
            self.present(alertController, animated: true)
        }else if self.titleTextFieldQutle.text == "" || self.remarkTextFieldQutlet.text == ""{
            let alertController = UIAlertController(title: R.string.localizable.warming(), message: "The title and remark can't Null", preferredStyle: .alert)
            let okActiojn = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okActiojn)
            self.present(alertController, animated: true)
        }else if (self.beginTime) > (self.endTime) {
            let alertController = UIAlertController(title: R.string.localizable.warming(), message: "Start time later than the end of time", preferredStyle: .alert)
            let okActiojn = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okActiojn)
            self.present(alertController, animated: true)
            
        }else
        {
          self.isSame = false
            //过滤
            for tod in self.todos
            {
                if tod?["topic"] as? String == self.titleTextFieldQutle.text
                {
                    self.isSame = true
                    let alertController = UIAlertController(title: R.string.localizable.warming(), message: "The existing of the same title to do list", preferredStyle: .alert)
                    let okActiojn = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okActiojn)
                    self.present(alertController, animated: true)
                    
                }
            }
           
            
            if !self.isSame!{
                
             if self.isOldTodo!{
                    
                    let _  = KidSettingsManager.shared.updateTodoList(KidSetting.Reminder.ToDo(topic: todo?["topic"] as? String ?? "", content: todo?["content"] as? String ?? "", start: (todo?["start"] as? Date)!, end: (todo?["end"] as? Date)!, repeatCount: repeatcount(name: repeatcountInt(Intt: (todo?["repeat"] as? Int)!))), new: KidSetting.Reminder.ToDo(topic: titleTextFieldQutle.text, content: remarkTextFieldQutlet.text, start: beginTimeVariable.value, end: (todo?["end"] as? Date)!, repeatCount: repeatcount(name: self.repeatStateVariable.value))).subscribe(onNext:
                        {
                            print($0)
                            if $0 {
                                let _ = self.navigationController?.popViewController(animated: true)
                            }else{
                                print("网络错误重新")
                            }
                    }).addDisposableTo(self.disposeBag)
             }else{
     
            let _ = KidSettingsManager.shared.creadTodoLis(KidSetting.Reminder.ToDo(topic: self.titleTextFieldQutle.text ?? "", content: self.remarkTextFieldQutlet.text ?? "", start: beginTime, end: endTime, repeatCount: repeatcount(name: self.repeatStateVariable.value))).subscribe(onNext:
                            {
                                print($0)
                                if $0 {
                                let _ = self.navigationController?.popViewController(animated: true)
                                }else{
                            print("网络错误重新")
                                }
                        }).addDisposableTo(self.disposeBag)
            }
                
            }
//        -------
        }
        
    }

    @IBAction func backAction(_ sender: Any) {
        
            _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
         let vc = R.storyboard.account.repeatViewController()!
        if cell == repeatCell {
            print("test")
            vc.repeatBlock = { repea in
                self.repeatStateVariable.value = repea
            }
            self.navigationController?.show(vc, sender: nil)
        }
    }
    
    func repeatcount(name: String) -> Int {
    
        return [R.string.localizable.never():0, R.string.localizable.everyday():1, R.string.localizable.everyweek() : 2, R.string.localizable.everymonth():3][name] ?? 0
        
    }
    func repeatcountInt(Intt: Int) -> String {
        
        let InttString = String(Intt)
        return ["0": R.string.localizable.never(),"1": R.string.localizable.everyday(),"2": R.string.localizable.everyweek(),"3": R.string.localizable.everymonth() ][InttString]!
    }

    private func selectBeginTime() {
        self.datePicker.datePickerMode = .dateAndTime
        self.datePicker.minimumDate = Date.today().startDate
        self.beginTimeQutle.isSelected = true
        self.endTimeQutle.isSelected = false
        self.datePicker.date = beginTime
        self.DatePickerView.isHidden = false
    }
    
    private func selectEndTime() {
        self.datePicker.datePickerMode = .time
        self.datePicker.date = beginTime
        self.datePicker.minimumDate = beginTime
        self.endTimeQutle.isSelected = true
        self.beginTimeQutle.isSelected = false
        self.datePicker.date = endTime
        self.DatePickerView.isHidden = false
        
    }
    
    private func cancelDatepicker() {
        DatePickerView.isHidden = true
        beginTimeQutle.isSelected = false
        endTimeQutle.isSelected = false
    }
    
    private func comfirmDatepicker() {
        
        if beginTimeQutle.isSelected {
            beginTimeQutle.isSelected = false
            beginTimeVariable.value = datePicker.date
        }
        
        if endTimeQutle.isSelected {
            endTimeQutle.isSelected = false
            endTimeVariabel.value = datePicker.date
        }
        
        DatePickerView.isHidden = true

        
    }

    
}
extension ToDoListController {
    
    fileprivate func stringchangeTime(dateString : String) -> Date{
        let dformatter = DateFormatter()
        dformatter.dateFormat = "MM-dd-yyyy HH:mm"
        return (dformatter.date(from: dateString)) ?? Date()
        
    }
    
    private func DateString(form date: Date) -> String {
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


