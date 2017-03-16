//
//  AlarmController.swift
//  Move App
//
//  Created by jiang.duan on 2017/2/27.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class AlarmController: UIViewController {
    //internationalization
    @IBOutlet weak var alarmTitleItem: UINavigationItem!
    @IBOutlet weak var saveOutlet: UIButton!
    
    
    
    @IBOutlet weak var datePickerOulet: UIDatePicker!
    @IBOutlet weak var weekOutlet: WeekView!
    
    var alarmExited: KidSetting.Reminder.Alarm?
    
    var activeVariable = Variable(true)
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
//        datePickerOulet.maximumDate = maxDate
        datePickerOulet.minimumDate = minDate
        if let _alarmDate = alarmExited?.alarmAt {
            datePickerOulet.date = _alarmDate
        }
        if let _day = alarmExited?.day {
            weekOutlet.weekSelected = _day
        }
        
        let viewModel = AlarmViewModel(
            input: (
                save: saveOutlet.rx.tap.asDriver(),
                week: weekOutlet.rx.weekSelected.asDriver(),
                alarmDate: datePickerOulet.rx.date.asDriver(),
                active: activeVariable.asDriver(),
                alarmExited: alarmExited
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
            .drive(saveOutlet.rx.isEnabled)
            .addDisposableTo(disposeBag)
    }
    

}

extension AlarmController {

    fileprivate var minDate: Date {
        return DateUtility.zoneDay().startDate
    }
    
    fileprivate var maxDate: Date {
        return DateUtility.zoneDay().endDate
    }
    
}
