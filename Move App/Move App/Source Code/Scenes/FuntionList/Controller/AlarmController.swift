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
    
    var alarms: NSDictionary?
    
    @IBOutlet weak var datePickerOulet: UIDatePicker!
    @IBOutlet weak var weekOutlet: WeekView!
    
    @IBOutlet weak var back: UIButton!
    
    var alarmExited: KidSetting.Reminder.Alarm?
    
    var activeVariable = Variable(true)
  
    var disposeBag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let btn = UIButton()
        btn.tag  = 10
        weekOutlet.weekAction(btn)
        
    }
    func internationalization() {
        alarmTitleItem.title = R.string.localizable.alarm()
        saveOutlet.setTitle(R.string.localizable.save(), for: .normal)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.internationalization()
        back.isHidden = false
        if alarms != nil {
            self.datePickerOulet.date = (alarms?["alarms"] as? Date ?? nil)!
            self.weekOutlet.weekSelected = (alarms?["dayFromWeek"] as? [Bool] ?? nil)!
//           back.isHidden = true
        }
       
        back.addTarget(self, action: "back", for: .touchUpInside)
        
        self.datePickerOulet.timeZone = TimeZone(secondsFromGMT: 0)
        
        let viewModel = AlarmViewModel(
            input: (
                save: saveOutlet.rx.tap.asDriver(),
                week: weekOutlet.rx.weekSelected.asDriver(),
                alarmDate: datePickerOulet.rx.date.asDriver(),
                active: activeVariable.asDriver()
//                alarmExited: alarmExited
            ),
            dependency: (
                kidSettingsManager: KidSettingsManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance))
        
//        viewModel.saveFinish
//            .drive(onNext: {[weak self] finish in
//                if finish {
//                    let _ = self?.navigationController?.popViewController(animated: true)
//                }
//            })
//            .addDisposableTo(disposeBag)
        viewModel.saveFinish
            .drive(onNext: back)
            .addDisposableTo(disposeBag)
        
        viewModel.activityIn
            .map({ !$0 })
            .drive(saveOutlet.rx.isEnabled)
            .addDisposableTo(disposeBag)
    }
    
    @IBAction func backAction(_ sender: Any) {
        if alarms != nil{
           
            let _ = KidSettingsManager.shared.creadAlarm(KidSetting.Reminder.Alarm(alarmAt: (alarms?["alarms"] as? Date ?? nil)!, day: (alarms?["dayFromWeek"] as? [Bool] ?? nil)!, active: true)).subscribe(onNext:
                {
                    print($0)
                    if $0 {
                        
                    }else{
                        
                    }
            }).addDisposableTo(self.disposeBag)
            
        }
        let time: TimeInterval = 0.7
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
            //code
             _ = self.navigationController?.popViewController(animated: true)
        }
        
        
    }
    
    func back(_ $: Bool) {
        if $ {
              _ = self.navigationController?.popViewController(animated: true)
        }
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
