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
    
    @IBOutlet weak var saveItemOutlet: UIBarButtonItem!
    var alarms: NSDictionary?
    
    @IBOutlet weak var datePickerOulet: UIDatePicker!
    @IBOutlet weak var weekOutlet: WeekView!
    
    @IBOutlet weak var back: UIButton!
    
    var alarmExited: KidSetting.Reminder.Alarm?
    
    var activeVariable = Variable(true)
  
    var disposeBag = DisposeBag()
    var isOldAlarm: Bool?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let btn = UIButton()
        btn.tag  = 10
        weekOutlet.weekAction(btn)
        
    }
    func internationalization() {
        alarmTitleItem.title = R.string.localizable.id_alarm()
//        saveOutlet.setTitle(R.string.localizable.id_save(), for: .normal)
        saveItemOutlet.title = R.string.localizable.id_save()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.internationalization()
        back.isHidden = false
        isOldAlarm = false
        
        if alarms != nil {
            self.datePickerOulet.date = (alarms?["alarms"] as? Date ?? nil)!
            self.weekOutlet.weekSelected = (alarms?["dayFromWeek"] as? [Bool])!
            isOldAlarm = true
        }
        

        self.saveItemOutlet.rx.tap.asDriver()
            .drive(onNext: saveAlarm)
            .addDisposableTo(disposeBag)
        
        self.datePickerOulet.timeZone = TimeZone(secondsFromGMT: 0)
        
//        let viewModel = AlarmViewModel(
//            input: (
//                save: saveOutlet.rx.tap.asDriver(),
//                week: weekOutlet.rx.weekSelected.asDriver(),
//                alarmDate: datePickerOulet.rx.date.asDriver(),
//                active: activeVariable.asDriver()
////                alarmExited: alarmExited
//            ),
//            dependency: (
//                kidSettingsManager: KidSettingsManager.shared,
//                validation: DefaultValidation.shared,
//                wireframe: DefaultWireframe.sharedInstance))
//        
////        viewModel.saveFinish
////            .drive(onNext: {[weak self] finish in
////                if finish {
////                    let _ = self?.navigationController?.popViewController(animated: true)
////                }
////            })
////            .addDisposableTo(disposeBag)
//        viewModel.saveFinish?
//            .drive(onNext: back)
//            .addDisposableTo(disposeBag)
//        
//        viewModel.activityIn
//            .map({ !$0 })
//            .drive(saveOutlet.rx.isEnabled)
//            .addDisposableTo(disposeBag)
    }
    //xib 连线返回按钮
    @IBAction func backAction(_ sender: Any) {

             _ = self.navigationController?.popViewController(animated: true)

    }
    //需求变动
    func sortWeek(_ flags: [Bool]) -> [Bool] {
        var fs = flags
                let flag = fs.first!
                _ = fs.remove(at: 0)
                _ = fs.append(flag)
        return fs
    }
    
    //保存
    func saveAlarm() {
        self.saveItemOutlet.isEnabled = false
        
        let _ = isOldAlarm! ? KidSettingsManager.shared.updateAlarm(KidSetting.Reminder.Alarm(alarmAt: (alarms?["alarms"] as? Date ?? nil)!, day: (alarms?["dayFromWeek"] as? [Bool])!, active: alarms?["active"] as? Bool), new: KidSetting.Reminder.Alarm(alarmAt: datePickerOulet.date, day: weekOutlet.weekSelected, active: alarms?["active"] as? Bool))
            .subscribe(onNext:
                {
                    print($0)
                    if $0 {
                        _ = self.navigationController?.popViewController(animated: true)
                    }else{
                        self.saveItemOutlet.isEnabled = true
                    }
            }).addDisposableTo(self.disposeBag) : KidSettingsManager.shared.creadAlarm(KidSetting.Reminder.Alarm(alarmAt: datePickerOulet.date, day: weekOutlet.weekSelected, active: true)).subscribe(onNext:
                {
                    print($0)
                    if $0 {
                        _ = self.navigationController?.popViewController(animated: true)
                    }else{
                        self.saveItemOutlet.isEnabled = true
                    }
            }).addDisposableTo(self.disposeBag)
        
        
    }

}
