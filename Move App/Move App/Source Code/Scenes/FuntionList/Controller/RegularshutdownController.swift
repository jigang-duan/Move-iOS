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
    var openShutdownVariabel = Variable(true)
    
    @IBOutlet weak var bootTimeOutlet: UIButton!
    
    @IBOutlet weak var shutdownTimeQutlet: UIButton!
    @IBOutlet weak var timeView: UIView!
    
    @IBOutlet weak var datePickView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
  
    
    
    @IBOutlet weak var saveItemOutlet: UIBarButtonItem!
    var viewModel: RegularshutdownViewModel?
    
    var bootTimeVariable = Variable(DateUtility.zone7hour())
    var shutdownTimeVariable = Variable(DateUtility.zone16hour())
    
    var disposeBag = DisposeBag()
    
    var touchesBeganEnable = Variable(false)
    
    private func internationalization() {
        regularshutdownTitleItem.title = R.string.localizable.id_regular_shutdown()
        automaticOnOffLabel.text =  R.string.localizable.id_automatic_power_on_off()
        booTimeLabel.text = R.string.localizable.id_boot_time()
        shutdownLabel.text = R.string.localizable.id_shutdown_time()
        saveItemOutlet.title = R.string.localizable.id_save()
        comfirmQutlet.setTitle(R.string.localizable.id_confirm(), for: .normal)
        cancelQutlet.setTitle(R.string.localizable.id_cancel(), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        internationalization()
        
        self.datePicker.timeZone = TimeZone(secondsFromGMT: 0)

       (openShutdown.rx.value <-> openShutdownVariabel).addDisposableTo(disposeBag)
        let openEnable = openShutdownVariabel.asDriver()
        
        openEnable
            .drive(onNext: {[weak self] in
                self?.enableView($0)
            })
            .addDisposableTo(disposeBag)
        
        openEnable
            .drive(touchesBeganEnable)
            .addDisposableTo(disposeBag)
        
      
        
        bootTimeVariable.asDriver()
            .drive(onNext: {[weak self] date in
                self?.bootTime = date
            })
            .addDisposableTo(disposeBag)
        
        self.bootTimeOutlet.rx.tap
            .asDriver()
            .drive(onNext:{[weak self] in
                self?.selectBootTime()
                })
            .addDisposableTo(disposeBag)
        
        shutdownTimeVariable.asDriver()
            .drive(onNext: { [weak self] date in
                self?.shutdownTime = date
            })
            .addDisposableTo(disposeBag)
        
        
        self.shutdownTimeQutlet.rx.tap
            .asDriver()
            .drive(onNext: {[weak self] in
                self?.selectShutdownTime()
            })
            .addDisposableTo(disposeBag)
        
        self.comfirmQutlet.rx.tap
            .asDriver()
            .drive(onNext: {[weak self] in
                self?.comfirmDatepicker()
            })
            .addDisposableTo(disposeBag)
       
        self.cancelQutlet.rx.tap
            .asDriver()
            .drive(onNext: {[weak self] in
                self?.cancelDatepicker()
            })
            .addDisposableTo(disposeBag)
        
        viewModel = RegularshutdownViewModel(
            input: (
                bootTime: bootTimeVariable.asDriver(),
                shutdownTime: shutdownTimeVariable.asDriver(),
                autoOnOff: openShutdownVariabel.asDriver(),
                save: saveItemOutlet.rx.tap.asDriver()
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
            .drive(onNext:{[weak self] in
                self?.enableView($0)
            })
            .addDisposableTo(disposeBag)
        
        viewModel?.autoOnOffEnable
            .drive(touchesBeganEnable)
            .addDisposableTo(disposeBag)
        
        viewModel?.activityIn
            .map{ !$0 }
            .drive(onNext: {[weak self] in
                
            })
            .addDisposableTo(disposeBag)
        
        
        viewModel?.saveFinish
            .drive(onNext: {[weak self] in
                self?.back($0)
                }
            ).addDisposableTo(disposeBag)
        
        
    }
    
    func back(_ $: Bool) {
        if $ {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }


    func userInteractionEnabled(enable: Bool) {
        
    }
  
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if touchesBeganEnable.value {
            datePickView.isHidden = true
            shutdownTimeQutlet.isSelected = false
            bootTimeOutlet.isSelected = false
        }
    }
    
}
//按钮监听事件
extension RegularshutdownController {
    
    func enableView(_ enable: Bool){
        
        self.bootTimeOutlet.isEnabled = enable
        self.shutdownTimeQutlet.isEnabled = enable
        self.datePickView.isHidden = enable ? self.datePickView.isHidden : true
        self.booTimeLabel.isEnabled = enable
        self.shutdownLabel.isEnabled = enable
    }

    
    func cancelDatepicker() {
        datePickView.isHidden = true
        bootTimeOutlet.isSelected = false
        shutdownTimeQutlet.isSelected = false
    }
    
    fileprivate func alertSeting(message: String,preferredStyle: UIAlertControllerStyle)
    {
        let alertController = UIAlertController(title: R.string.localizable.id_warming(), message: message, preferredStyle: preferredStyle)
        let okActiojn = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okActiojn)
        
        self.present(alertController, animated: true)
    }
    
     func comfirmDatepicker() {
        
        if bootTimeOutlet.isSelected {
            bootTimeOutlet.isSelected = false
            let selectTime = Double(datePicker.date.timeIntervalSince1970)
            let currTime = Double(shutdownTimeVariable.value.timeIntervalSince1970)
            let result = selectTime - currTime
            if (datePicker.date == shutdownTimeVariable.value) ||  (fabsf(Float(result)) <= 540) {
                
                self.alertSeting(message: R.string.localizable.id_time_interval_too_short(), preferredStyle: .alert)
                
            }else
            {
                bootTimeVariable.value = datePicker.date
                
            }
        }
        
        if shutdownTimeQutlet.isSelected {
            shutdownTimeQutlet.isSelected = false
            let selectTime = Double(datePicker.date.timeIntervalSince1970)
            let currTime = Double(bootTimeVariable.value.timeIntervalSince1970)
            let result = selectTime - currTime
            if (datePicker.date == bootTimeVariable.value) || (fabsf(Float(result)) <= 540) {
                
                self.alertSeting(message: R.string.localizable.id_time_interval_too_short(), preferredStyle: .alert)
                
            }else
            {
                shutdownTimeVariable.value = datePicker.date
                
            }
            
        }
        
        datePickView.isHidden = true
        openShutdown.isOn = true
    }
    
     func selectShutdownTime() {
        self.datePicker.minimumDate = self.amMin
        self.datePicker.maximumDate = self.pmMax
        self.shutdownTimeQutlet.isSelected = true
        self.bootTimeOutlet.isSelected = false
        self.datePicker.date = shutdownTime
        self.datePickView.isHidden = false
        
    }
    
     func selectBootTime() {
        self.datePicker.minimumDate = self.amMin
        self.datePicker.maximumDate = self.pmMax
        self.bootTimeOutlet.isSelected = true
        self.shutdownTimeQutlet.isSelected = false
        self.datePicker.date = bootTime
        self.datePickView.isHidden = false
    }

}

//时间转换
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
