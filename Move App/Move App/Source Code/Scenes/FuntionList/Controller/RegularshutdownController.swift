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
    
    @IBOutlet weak var openShutdown: SwitchButton!
    
    @IBOutlet weak var booTimeLabel: UILabel!
    @IBOutlet weak var bootTimeOutlet: UIButton!
    @IBOutlet weak var shutdownLabel: UILabel!
    @IBOutlet weak var shutdownTimeQutlet: UIButton!
    @IBOutlet weak var timeView: UIView!
    
    
    @IBOutlet weak var datePickView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var cancelQutlet: UIButton!
    @IBOutlet weak var comfirmQutlet: UIButton!
    
    @IBOutlet weak var SaveQutlet: UIButton!
    
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
        
        shutdownTimeVariable.asDriver()
            .drive(onNext: { date in
                self.shutdownTime = date
            })
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
        
        let viewModel = RegularshutdownViewModel(
            input: (
                save: SaveQutlet.rx.tap.asDriver(),
                bootTime: bootTimeVariable.asDriver(),
                shutdownTime: shutdownTimeVariable.asDriver(),
                openEnable: openEnable.asDriver()
                ),
                dependency: (
                    settingsManager: WatchSettingsManager.share,
                    validation: DefaultValidation.shared,
                    wireframe: DefaultWireframe.sharedInstance)
        )
        
        viewModel.shutdownTime
            .drive(self.shutdownTimeVariable)
            .addDisposableTo(disposeBag)
        
        viewModel.bootTime
            .drive(self.bootTimeVariable)
            .addDisposableTo(disposeBag)
        
        viewModel.openEnable
            .drive(openShutdown.rx.on)
            .addDisposableTo(disposeBag)
        
        viewModel.openEnable
            .drive(onNext: enableView)
            .addDisposableTo(disposeBag)
        
        viewModel.openEnable
            .drive(touchesBeganEnable)
            .addDisposableTo(disposeBag)
        
        viewModel.activityIn
            .map{ !$0 }
            .drive(SaveQutlet.rx.isEnabled)
            .addDisposableTo(disposeBag)
    }

    private func cancelDatepicker() {
        datePickView.isHidden = true
        bootTimeOutlet.isEnabled = true
        shutdownTimeQutlet.isEnabled = true
    }
    
    private func comfirmDatepicker() {
        
        if !bootTimeOutlet.isEnabled {
            
            bootTimeOutlet.isEnabled = true
            bootTimeVariable.value = datePicker.date
        }
        
        if !shutdownTimeQutlet.isEnabled {
            shutdownTimeQutlet.isEnabled = true
            shutdownTimeVariable.value = datePicker.date
        }
       
        datePickView.isHidden = true
        
        
    }
    
    private func selectShutdownTime() {
        self.datePicker.minimumDate = self.amMin
        self.datePicker.maximumDate = self.pmMax
        self.shutdownTimeQutlet.isEnabled = false
        self.bootTimeOutlet.isEnabled = true
        self.datePicker.date = shutdownTime
        self.datePickView.isHidden = false
    
    }
    
    private func selectBootTime() {
        self.datePicker.minimumDate = self.amMin
        self.datePicker.maximumDate = self.pmMax
        self.bootTimeOutlet.isEnabled = false
        self.shutdownTimeQutlet.isEnabled = true
        self.datePicker.date = bootTime
        self.datePickView.isHidden = false
    }
    
    private func enableView(_ enable: Bool){
        self.bootTimeOutlet.isEnabled = enable
        self.shutdownTimeQutlet.isEnabled = enable
       
       
        self.datePickView.isHidden = enable ? self.datePickView.isHidden : true
        self.timeView.isHidden = !enable
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if touchesBeganEnable.value {
            datePickView.isHidden = true
            shutdownTimeQutlet.isEnabled = true
            bootTimeOutlet.isEnabled = true
            
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
