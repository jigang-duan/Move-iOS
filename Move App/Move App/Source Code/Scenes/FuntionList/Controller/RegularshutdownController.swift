//
//  RegularshutdownController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/23.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import CustomViews
import RxSwift
import RxCocoa

class RegularshutdownController: UIViewController {
     //internationalization
    @IBOutlet weak var regularshutdownTitleItem: UINavigationItem!
    @IBOutlet weak var automaticOnOffLabel: UILabel!
    @IBOutlet weak var booTimeLabel: UILabel!
    @IBOutlet weak var shutdownLabel: UILabel!
    @IBOutlet weak var cancelQutlet: UIButton!
    @IBOutlet weak var comfirmQutlet: UIButton!
    
    @IBOutlet weak var openShutdown: SwitchButton!

    @IBOutlet weak var bootTimeOutlet: UIButton!
    
    @IBOutlet weak var shutdownTimeQutlet: UIButton!
    @IBOutlet weak var timeView: UIView!
    
    @IBOutlet weak var datePickView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
  
    
    var viewModel: RegularshutdownViewModel?
    
    var bootTimeVariable = Variable(DateUtility.zone7hour())
    var shutdownTimeVariable = Variable(DateUtility.zone16hour())
    
    var disposeBag = DisposeBag()
    
    var touchesBeganEnable = Variable(false)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.datePicker.timeZone = TimeZone(secondsFromGMT: 0)
        
        let openEnable = openShutdown.rx.switch.asDriver()
        
        openEnable
            .drive(onNext: enableView)
            .addDisposableTo(disposeBag)
        
        openEnable
            .drive(touchesBeganEnable)
            .addDisposableTo(disposeBag)
        
        bootTimeVariable.asDriver()
            .drive(onNext: {date in
                self.bootTime = date
            })
            .addDisposableTo(disposeBag)
        
        self.bootTimeOutlet.rx.tap
            .asDriver()
            .drive(onNext: selectBootTime)
            .addDisposableTo(disposeBag)
        
        shutdownTimeVariable.asDriver()
            .drive(onNext: { date in
                self.shutdownTime = date
            })
            .addDisposableTo(disposeBag)
        
        
        self.shutdownTimeQutlet.rx.tap
            .asDriver()
            .drive(onNext: selectShutdownTime)
            .addDisposableTo(disposeBag)
        
        self.comfirmQutlet.rx.tap
            .asDriver()
            .drive(onNext: comfirmDatepicker)
            .addDisposableTo(disposeBag)
        
        self.cancelQutlet.rx.tap
            .asDriver()
            .drive(onNext: cancelDatepicker)
            .addDisposableTo(disposeBag)
        
        viewModel = RegularshutdownViewModel(
            input: (
                bootTime: bootTimeVariable.asDriver(),
                shutdownTime: shutdownTimeVariable.asDriver(),
                autoOnOff: openShutdown.rx.value.asDriver(),
                save: comfirmQutlet.rx.tap.asDriver()
                ),
                dependency: (
                    settingsManager: WatchSettingsManager.share,
                    validation: DefaultValidation.shared,
                    wireframe: DefaultWireframe.sharedInstance)
        )
        
        
        viewModel?.shutdownTime
            .drive(self.shutdownTimeVariable)
            .addDisposableTo(disposeBag)
        
        viewModel?.bootTime
            .drive(self.bootTimeVariable)
            .addDisposableTo(disposeBag)
        
        viewModel?.autoOnOffEnable
            .drive(openShutdown.rx.on)
            .addDisposableTo(disposeBag)
        
        viewModel?.autoOnOffEnable
            .drive(onNext: enableView)
            .addDisposableTo(disposeBag)
        viewModel?.autoOnOffEnable
            .drive(touchesBeganEnable)
            .addDisposableTo(disposeBag)
        viewModel?.activityIn
            .map{ !$0 }
            .drive(onNext: userInteractionEnabled)
            .addDisposableTo(disposeBag)
        
        
        viewModel?.saveFinish
            .drive(onNext: {_ in
            }).addDisposableTo(disposeBag)
        
        
    }

    func userInteractionEnabled(enable: Bool) {
        
    }
    private func cancelDatepicker() {
        datePickView.isHidden = true
        bootTimeOutlet.isSelected = false
        shutdownTimeQutlet.isSelected = false
    }
    
    private func comfirmDatepicker() {
        
        if bootTimeOutlet.isSelected {
            bootTimeOutlet.isSelected = false
            bootTimeVariable.value = datePicker.date
        }
        
        if shutdownTimeQutlet.isSelected {
            shutdownTimeQutlet.isSelected = false
            shutdownTimeVariable.value = datePicker.date
        }
       
        datePickView.isHidden = true
        
//        openShutdown.rx.switch.startWith(true).asObservable()

        viewModel?.saveFinish
            .drive(onNext: {_ in
            }).addDisposableTo(disposeBag)

        
    }
    
    private func selectShutdownTime() {
        self.datePicker.minimumDate = self.amMin
        self.datePicker.maximumDate = self.pmMax
        self.shutdownTimeQutlet.isSelected = true
        self.bootTimeOutlet.isSelected = false
        self.datePicker.date = shutdownTime
        self.datePickView.isHidden = false
    
    }
    
    private func selectBootTime() {
        self.datePicker.minimumDate = self.amMin
        self.datePicker.maximumDate = self.pmMax
        self.bootTimeOutlet.isSelected = true
        self.shutdownTimeQutlet.isSelected = false
        self.datePicker.date = bootTime
        self.datePickView.isHidden = false
    }
    
    private func enableView(_ enable: Bool){
        self.bootTimeOutlet.isEnabled = enable
        self.shutdownTimeQutlet.isEnabled = enable
        self.datePickView.isHidden = enable ? self.datePickView.isHidden : true
        self.booTimeLabel.isEnabled = enable
        self.shutdownLabel.isEnabled = enable
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if touchesBeganEnable.value {
            datePickView.isHidden = true
            shutdownTimeQutlet.isSelected = false
            bootTimeOutlet.isSelected = false
            
        }
    }
    
}

extension RegularshutdownController {
    
    private func zoneDateString(form date: Date) -> String {
        let dformatter = DateFormatter()
        dformatter.timeZone = TimeZone(secondsFromGMT: 0)
        dformatter.dateFormat = "HH:mm"
        let dateStr = dformatter.string(from: date)
        return dateStr
    }
    
    
    fileprivate var bootTime: Date {
        get {
            return  DateUtility.zoneDayOfHMS(date: DateUtility.date(from: bootTimeOutlet.titleLabel?.text))
        }
        set(newValue) {
            bootTimeOutlet.setTitle(zoneDateString(form: newValue), for: .normal)
        }
    }
    
    fileprivate var shutdownTime: Date {
        get {
            return  DateUtility.zoneDayOfHMS(date: DateUtility.date(from: shutdownTimeQutlet.titleLabel?.text))
        }
        set(newValue) {
            shutdownTimeQutlet.setTitle(zoneDateString(form: newValue), for: .normal)
        }
    }
    
    
    fileprivate var amMin: Date {
        return DateUtility.zoneDay().startDate
    }
    
    fileprivate var pmMax: Date {
        return DateUtility.zoneDay().endDate
    }

}
