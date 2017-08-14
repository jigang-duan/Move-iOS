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
    
    @IBOutlet weak var saveItemOutlet: UIBarButtonItem!
    
    @IBOutlet weak var datePickerOulet: UIDatePicker!
    @IBOutlet weak var weekOutlet: WeekView!
    
    var isForAdd = false
    
    var alarm: KidSetting.Reminder.Alarm?
    
    var disposeBag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let btn = UIButton()
        btn.tag  = 10
        weekOutlet.weekAction(btn)
    }
    
    private func internationalization() {
        self.title = R.string.localizable.id_title_Alarm()
        saveItemOutlet.title = R.string.localizable.id_save()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        internationalization()
        
        if isForAdd == false {
            self.datePickerOulet.date = alarm?.alarmAt ?? Date(timeIntervalSince1970: 0)
            self.weekOutlet.weekSelected = alarm?.day ?? [false,false,false,false,false,false,false]
        }
        
        self.saveItemOutlet.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.saveAlarm()
            })
            .addDisposableTo(disposeBag)
        
        self.datePickerOulet.timeZone = TimeZone(secondsFromGMT: 0)
        
    }
    
    func saveAlarm() {
        self.saveItemOutlet.isEnabled = false
        
        if isForAdd == true {
            KidSettingsManager.shared.addAlarm(KidSetting.Reminder.Alarm(alarmAt: datePickerOulet.date, day: weekOutlet.weekSelected, active: true)).subscribe(onNext:{ [weak self] in
                    if $0 {
                        _ = self?.navigationController?.popViewController(animated: true)
                    }else{
                        self?.saveItemOutlet.isEnabled = true
                    }
            }).addDisposableTo(self.disposeBag)
        }else{
            KidSettingsManager.shared.updateAlarm(alarm!, new: KidSetting.Reminder.Alarm(alarmAt: datePickerOulet.date, day: weekOutlet.weekSelected, active: alarm?.active))
                .subscribe(onNext:{ [weak self] in
                    if $0 {
                        _ = self?.navigationController?.popViewController(animated: true)
                    }else{
                        self?.saveItemOutlet.isEnabled = true
                    }
                })
                .addDisposableTo(self.disposeBag)
        }
    }
    
}
