//
//  SchoolTimeController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/22.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import CustomViews
import RxSwift
import RxCocoa


class SchoolTimeController: UIViewController {
    //internationalization
    @IBOutlet weak var schooltimeTitleItem: UINavigationItem!
    @IBOutlet weak var saveOutlet: UIButton!
    @IBOutlet weak var openschooltimeLabel: UILabel!
    @IBOutlet weak var anLabel: UILabel!
    @IBOutlet weak var pmLabel: UILabel!
    @IBOutlet weak var confirmOutlet: UIButton!
    @IBOutlet weak var cancelDatePickeOutlet: UIButton!
    
    
    @IBOutlet weak var openSchoolSwitch: SwitchButton!
    
    @IBOutlet weak var datePickView: UIView!
    @IBOutlet weak var datepicke: UIDatePicker!
    
    @IBOutlet weak var amStartTimeOutlet: UIButton!
    @IBOutlet weak var amEndTimeOutlet: UIButton!
    @IBOutlet weak var pmStartTimeOutlet: UIButton!
    @IBOutlet weak var pmEndTimeOutlet: UIButton!
    
    
    @IBOutlet weak var weekOutlet: WeekView!
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var amOutlet: UILabel!
    @IBOutlet weak var pmOutlet: UILabel!
    
    @IBOutlet weak var helpBtnQutlet: UIButton!
    @IBOutlet weak var NullQutlet: UIButton!
    
    var touchesBeganEnable = Variable(false)
    
    var viewModel: SchoolTimeViewModel!
    
    func internationalization() {
        schooltimeTitleItem.title = R.string.localizable.school_time()
        saveOutlet.setTitle(R.string.localizable.save(), for: .normal)
        anLabel.text = R.string.localizable.date_am()
        pmLabel.text = R.string.localizable.date_pm()
        confirmOutlet.setTitle(R.string.localizable.confirm(), for: .normal)
        cancelDatePickeOutlet.setTitle(R.string.localizable.cancel(), for: .normal)
        
        
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.internationalization()
        
        if Preferences.shared.mkSchoolTimeFirst {
         self.helpView()
         Preferences.shared.mkSchoolTimeFirst = false
        }
        helpBtnQutlet.rx.tap
            .asDriver()
            .drive(onNext: helpView)
            .addDisposableTo(disposeBag)
        
        
        self.datepicke.timeZone = TimeZone(secondsFromGMT: 0)
        let openEnable = openSchoolSwitch.rx.switch.asDriver()
        
        openEnable
            .drive(onNext: enableView)
            .addDisposableTo(disposeBag)
        
        openEnable
            .drive(touchesBeganEnable)
            .addDisposableTo(disposeBag)
        
        self.NullQutlet.rx.tap.asDriver()
            .drive(onNext: selectNullTime)
            .addDisposableTo(disposeBag)
        
        self.amStartTimeOutlet.rx.tap
            .asDriver()
            .drive(onNext: selectAmStartTime)
            .addDisposableTo(disposeBag)
        
        self.amEndTimeOutlet.rx.tap
            .asDriver()
            .drive(onNext: selectAmEndTime)
            .addDisposableTo(disposeBag)
        
        self.pmStartTimeOutlet.rx.tap
            .asDriver()
            .drive(onNext: selectPmStartTime)
            .addDisposableTo(disposeBag)
        
        self.pmEndTimeOutlet.rx.tap
            .asDriver()
            .drive(onNext: selectPmEndTime)
            .addDisposableTo(disposeBag)
        
        self.confirmOutlet.rx.tap
            .asDriver()
            .drive(onNext: comfirmDatepicker)
            .addDisposableTo(disposeBag)
        
        self.cancelDatePickeOutlet.rx.tap
            .asDriver()
            .drive(onNext: cancelDatepicker)
            .addDisposableTo(disposeBag)
        
        self.datepicke.rx.date
            .asDriver()
            .map(dateOtherFromSelected)
            .drive(confirmOutlet.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        viewModel = SchoolTimeViewModel(
            input: (
                save: saveOutlet.rx.tap.asDriver(),
                empty: Void()
            ),
            dependency: (
                kidSettingsManager: KidSettingsManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance,
                disposeBag: disposeBag
                )
        )
        
        viewModel.amStartDateVariable.asDriver().drive(onNext: { date in self.amStartTime = date }).addDisposableTo(disposeBag)
        viewModel.amEndDateVariable.asDriver() .drive(onNext: { date in self.amEndTime = date }).addDisposableTo(disposeBag)
        viewModel.pmStartDateVariable.asDriver().drive(onNext: { date in self.pmStartTime = date }).addDisposableTo(disposeBag)
        viewModel.pmEndDateVariable.asDriver().drive(onNext: { date in self.pmEndTime = date }).addDisposableTo(disposeBag)
        
        
        viewModel.saveFinish?
            .drive(onNext: { [weak self] finish in
                if finish {
                        _ = self?.navigationController?.popViewController(animated: true)
                    }
              
                
            })
            .addDisposableTo(disposeBag)
        
        (weekOutlet.rx.value <-> viewModel.dayFromWeekVariable).addDisposableTo(disposeBag)
        (openSchoolSwitch.rx.value <-> viewModel.openEnableVariable).addDisposableTo(disposeBag)
        
        viewModel.openEnableVariable.asDriver()
            .drive(onNext: enableView)
            .addDisposableTo(disposeBag)
        
        viewModel.openEnableVariable.asDriver()
            .drive(touchesBeganEnable)
            .addDisposableTo(disposeBag)
        
        viewModel.activityIn
            .map { !$0 }
            .drive(saveOutlet.rx.isEnabled)
            .addDisposableTo(disposeBag)
    }
    
    //
    /// MARK: -- Private
    //
    
 private  func helpView() {
        let view = Bundle.main.loadNibNamed("schoolTimeHelp", owner: nil, options: nil)?[0] as! UIView
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        let window = UIApplication.shared.windows[0]
        
        window.addSubview(view)
    }
    private func enableView(_ enable: Bool) {
        self.amOutlet.isEnabled = enable
        self.pmOutlet.isEnabled = enable
        self.weekOutlet.isEnable = enable
        self.amStartTimeOutlet.isEnabled = enable
        self.amEndTimeOutlet.isEnabled = enable
        self.pmStartTimeOutlet.isEnabled = enable
        self.pmEndTimeOutlet.isEnabled = enable
        self.datePickView.isHidden = enable ? self.datePickView.isHidden : true
    }
    
    private func selectAmStartTime() {
        self.datepicke.minimumDate = self.amMin
        self.datepicke.maximumDate = self.amMax
        self.amStartTimeOutlet.isSelected = true
        self.amEndTimeOutlet.isSelected = false
        self.pmStartTimeOutlet.isSelected = false
        self.pmEndTimeOutlet.isSelected = false
        self.datepicke.date = amStartTime
        self.datePickView.isHidden = false
    }
    
    private func selectAmEndTime() {
        self.datepicke.minimumDate = amStartTime + 60
        self.datepicke.maximumDate = self.amMax
        self.amStartTimeOutlet.isSelected = false
        self.amEndTimeOutlet.isSelected = true
        self.pmStartTimeOutlet.isSelected = false
        self.pmEndTimeOutlet.isSelected = false
        self.datepicke.date = amEndTime
        self.datePickView.isHidden = false
    }
    
    private func selectPmStartTime() {
        self.datepicke.minimumDate = self.pmMin
        self.datepicke.maximumDate = self.pmMax
        self.amStartTimeOutlet.isSelected = false
        self.amEndTimeOutlet.isSelected = false
        self.pmStartTimeOutlet.isSelected = true
        self.pmEndTimeOutlet.isSelected = false
        self.datepicke.date = pmStartTime
        self.datePickView.isHidden = false
    }
    
    private func selectPmEndTime() {
        self.datepicke.minimumDate = pmStartTime + 60
        self.datepicke.maximumDate = self.pmMax
        self.amStartTimeOutlet.isSelected = false
        self.amEndTimeOutlet.isSelected = false
        self.pmStartTimeOutlet.isSelected = false
        self.pmEndTimeOutlet.isSelected = true
        self.datepicke.date = pmEndTime
        self.datePickView.isHidden = false
    }
    
    private func cancelDatepicker() {
        datePickView.isHidden = true
        amStartTimeOutlet.isSelected = false
        amEndTimeOutlet.isSelected = false
        pmStartTimeOutlet.isSelected = false
    }
    
    private func selectNullTime() {
        if amStartTimeOutlet.isSelected {
            viewModel.amStartDateVariable.value = Date(timeIntervalSince1970: 0)
            viewModel.amEndDateVariable.value = Date(timeIntervalSince1970: 0)
            amStartTimeOutlet.isSelected = false
        }
        if amEndTimeOutlet.isSelected {
            viewModel.amStartDateVariable.value = Date(timeIntervalSince1970: 0)
            viewModel.amEndDateVariable.value = Date(timeIntervalSince1970: 0)
            amEndTimeOutlet.isSelected = false
        }
        if pmStartTimeOutlet.isSelected {
             viewModel.pmStartDateVariable.value = Date(timeIntervalSince1970: 0)
             viewModel.pmEndDateVariable.value = Date(timeIntervalSince1970: 0)
             pmStartTimeOutlet.isSelected = false
         }
         if pmEndTimeOutlet.isSelected {
             viewModel.pmStartDateVariable.value = Date(timeIntervalSince1970: 0)
             viewModel.pmEndDateVariable.value = Date(timeIntervalSince1970: 0)
             pmEndTimeOutlet.isSelected = false
         }
         
         datePickView.isHidden = true
 
     }

    private func comfirmDatepicker() {
        if amStartTimeOutlet.isSelected {
            if self.amStartTime == Date(timeIntervalSince1970: 0){
                viewModel.amStartDateVariable.value = datepicke.date
                amStartTimeOutlet.isSelected = false
            }
            else
            {
            if datepicke.date > self.amEndTime{
                let alertController = UIAlertController(title: R.string.localizable.warming(), message: "On the morning of the start time later than the end of time", preferredStyle: .alert)
                                        let okActiojn = UIAlertAction(title: "OK", style: .default, handler: nil)
                                        alertController.addAction(okActiojn)
                                        self.present(alertController, animated: true)
                amStartTimeOutlet.isSelected = false
            }else
            {
                viewModel.amStartDateVariable.value = datepicke.date
                amStartTimeOutlet.isSelected = false
            }
            }
        }
        if amEndTimeOutlet.isSelected {
                if self.amEndTime == Date(timeIntervalSince1970: 0)
                {
                    viewModel.amEndDateVariable.value = datepicke.date
                    amEndTimeOutlet.isSelected = false
                }
                else
                {
              if datepicke.date < self.amStartTime{
                let alertController = UIAlertController(title: R.string.localizable.warming(), message: "On the morning of the start time later than the end of time", preferredStyle: .alert)
                let okActiojn = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okActiojn)
                self.present(alertController, animated: true)
                amEndTimeOutlet.isSelected = false
            }
            else
            {
                viewModel.amEndDateVariable.value = datepicke.date
                amEndTimeOutlet.isSelected = false
            }
            }
        }
        if pmStartTimeOutlet.isSelected {
            if self.pmEndTime == Date(timeIntervalSince1970: 0)
            {
                viewModel.pmStartDateVariable.value = datepicke.date
                pmStartTimeOutlet.isSelected = false
            }
            else
            {
            if datepicke.date > self.pmEndTime{
                let alertController = UIAlertController(title: R.string.localizable.warming(), message: "On the afernoon of the start time later than the end of time", preferredStyle: .alert)
                                        let okActiojn = UIAlertAction(title: "OK", style: .default, handler: nil)
                                        alertController.addAction(okActiojn)
                                        self.present(alertController, animated: true)

                pmStartTimeOutlet.isSelected = false
            }else
            {
                viewModel.pmStartDateVariable.value = datepicke.date
                pmStartTimeOutlet.isSelected = false
                }
            }
            
        }
        if pmEndTimeOutlet.isSelected {
            if self.pmStartTime == Date(timeIntervalSince1970: 0)
            {
                viewModel.pmEndDateVariable.value = datepicke.date
                pmEndTimeOutlet.isSelected = false
            }
            else
            {
            if datepicke.date < self.pmStartTime{
                let alertController = UIAlertController(title: R.string.localizable.warming(), message: "On the afernoon of the start time later than the end of time", preferredStyle: .alert)
                                        let okActiojn = UIAlertAction(title: "OK", style: .default, handler: nil)
                                        alertController.addAction(okActiojn)
                                        self.present(alertController, animated: true)

                pmEndTimeOutlet.isSelected = false
            }else
            {
                viewModel.pmEndDateVariable.value = datepicke.date
                pmEndTimeOutlet.isSelected = false
            }
            }
        }
        
        datePickView.isHidden = true
    }
    
    private func dateOtherFromSelected(date: Date) -> Bool {
        if !amStartTimeOutlet.isEnabled {
            let time = self.amEndTime
            let comp = time.compare(date)
            return (comp == .orderedDescending)
        }
        if !amEndTimeOutlet.isEnabled {
            let time = self.amStartTime
            let comp = time.compare(date)
            return comp == .orderedAscending
        }
        if !pmStartTimeOutlet.isEnabled {
            let time = self.pmEndTime
            let comp = time.compare(date)
            return comp == .orderedDescending
        }
        if !pmEndTimeOutlet.isEnabled {
            let time = self.pmStartTime
            let comp = time.compare(date)
            return comp == .orderedAscending
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touchesBeganEnable.value {
            datePickView.isHidden = true
            amStartTimeOutlet.isSelected = false
            amEndTimeOutlet.isSelected = false
            pmStartTimeOutlet.isSelected = false
            pmEndTimeOutlet.isSelected = false
        }
    }
    
}

extension SchoolTimeController {
    
    private func zoneDateString(form date: Date) -> String {
        if date == Date(timeIntervalSince1970: 0){
            return "Null"
        }
        else
        {
        let dformatter = DateFormatter()
        dformatter.timeZone = TimeZone(secondsFromGMT: 0)
        dformatter.dateFormat = "HH:mm"
        let dateStr = dformatter.string(from: date)
        return dateStr
        }
    }
    
    fileprivate var amStartTime: Date {
        get {
            return  DateUtility.zoneDayOfHMS(date: DateUtility.date(from: amStartTimeOutlet.titleLabel?.text))
        }
        set(newValue) {
            amStartTimeOutlet.setTitle(zoneDateString(form: newValue), for: .normal)
        }
    }
    
    fileprivate var amEndTime: Date {
        get {
            return  DateUtility.zoneDayOfHMS(date: DateUtility.date(from: amEndTimeOutlet.titleLabel?.text))
        }
        set(newValue) {
            amEndTimeOutlet.setTitle(zoneDateString(form: newValue), for: .normal)
            
        }
    }
    
    fileprivate var pmStartTime: Date {
        get {
            return  DateUtility.zoneDayOfHMS(date: DateUtility.date(from: pmStartTimeOutlet.titleLabel?.text))
        }
        set(newValue) {
            pmStartTimeOutlet.setTitle(zoneDateString(form: newValue), for: .normal)
        }
    }
    
    fileprivate var pmEndTime: Date {
        get {
            return  DateUtility.zoneDayOfHMS(date: DateUtility.date(from: pmEndTimeOutlet.titleLabel?.text))
        }
        set(newValue) {
            pmEndTimeOutlet.setTitle(zoneDateString(form: newValue), for: .normal)
        }
    }
    
    
    fileprivate var amMin: Date {
        return DateUtility.zoneDay().startDate
    }
    
    fileprivate var amMax: Date {
        return DateUtility.zoneDay().startDate.addingTimeInterval(DateUtility.SEC_HDAY-1)
    }
    
    fileprivate var pmMin: Date {
        return DateUtility.zoneDay().startDate.addingTimeInterval(DateUtility.SEC_HDAY)
    }
    
    fileprivate var pmMax: Date {
        return DateUtility.zoneDay().endDate
    }
    
}

