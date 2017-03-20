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
    
    
    @IBOutlet weak var beginTimeQutlet: UITextField!
    @IBOutlet weak var endTimeQutlet: UITextField!

    @IBOutlet weak var repeatCell: UITableViewCell!
    @IBOutlet weak var repeatStateQutlet: UILabel!
    
    var todo: NSDictionary?
    
    var disposeBag = DisposeBag()
    
    
    var repeatStateVariable = Variable("Never")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if todo != nil{
            titleTextFieldQutle.text = todo?["topic"] as? String
            remarkTextFieldQutlet.text = todo?["content"] as? String
            beginTimeQutlet.text = DateUtility.dateTostringMMddyy(date: todo?["start"] as? Date)
            endTimeQutlet.text = DateUtility.dateTostringMMddyy(date: todo?["end"] as? Date)
            repeatStateVariable.value = repeatcountInt(Intt: (todo?["repeat"] as? Int)!)
        }
        
        tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0)
        beginTimeQutlet.inputView = self.datepickerInput()
        endTimeQutlet.inputView = self.datepickerInput()

        repeatStateVariable.asDriver().drive(repeatStateQutlet.rx.text).addDisposableTo(disposeBag)
        
        let viewModel = ToDoListViewModel(
            input: (
                save: saveQutlet.rx.tap.asDriver(),
                topic: titleTextFieldQutle.rx.text.orEmpty.asDriver(),
                content: remarkTextFieldQutlet.rx.text.orEmpty.asDriver(),
                startime: beginTimeQutlet.rx.text.orEmpty.asDriver().map(stringchangeTime),
                endtime: endTimeQutlet.rx.text.orEmpty.asDriver().map(stringchangeTime),
                repeatcount: repeatStateVariable.asDriver().map(repeatcount).debug()
            ),
            dependency: (
                kidSettingsManager: KidSettingsManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance))
        
        viewModel.saveFinish
            .drive(onNext: {[weak self] finish in
                if finish {
                    let _ = self?.navigationController?.popViewController(animated: true)
                }
            })
            .addDisposableTo(disposeBag)
      
        viewModel.activityIn
            .map({ !$0 })
            .drive(saveQutlet.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
    }
    
   
    
    func datepickerInput() -> UIDatePicker {
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 180))
        datePicker.locale = Locale(identifier: "en_GB")
        return datePicker
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
    
        return ["Never":0, "Every day":1, "Every week" : 2, "Every month":3][name] ?? 0
        
    }
    func repeatcountInt(Intt: Int) -> String {
        
        let InttString = String(Intt)
        return ["0": "Never","1": "Every day","2": "Every week","3": "Every month" ][InttString]!
    }

    
}

extension ToDoListController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let datePicker = textField.inputView as? UIDatePicker {
            textField.text = datePicker.date.stringMonthDayYearHourMinute
        }
        

       
    }
    

    
    fileprivate func stringchangeTime(dateString : String) -> Date{
        let dformatter = DateFormatter()
        dformatter.dateFormat = "MM-dd-yyyy"
        return (dformatter.date(from: dateString)) ?? Date()
        
    }
    
}

extension Date {
    
    var stringMonthDayYearHourMinute: String? {
        let dformatter = DateFormatter()
        dformatter.dateFormat = "MM-dd-yyyy"
        return dformatter.string(from: self)
    }
}


