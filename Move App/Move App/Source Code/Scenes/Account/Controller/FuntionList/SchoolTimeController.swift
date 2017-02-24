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
    
    @IBOutlet weak var openSchoolSwitch: SwitchButton!
    
    @IBOutlet weak var datePickView: UIView!
    @IBOutlet weak var datepicke: UIDatePicker!
    @IBOutlet weak var confirmOutlet: UIButton!
    @IBOutlet weak var cancelDatePickeOutlet: UIButton!
    
    
    @IBOutlet weak var amStartTimeOutlet: UIButton!
    @IBOutlet weak var amEndTimeOutlet: UIButton!
    @IBOutlet weak var pmStartTimeOutlet: UIButton!
    @IBOutlet weak var pmEndTimeOutlet: UIButton!
    
    
    @IBOutlet weak var saveOutlet: UIBarButtonItem!
    @IBOutlet weak var weekOutlet: WeekView!
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var amOutlet: UILabel!
    @IBOutlet weak var pmOutlet: UILabel!
    
    var touchesBeganEnable = Variable(false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.datepicke.timeZone = TimeZone(secondsFromGMT: 0)
        
        let openEnable = openSchoolSwitch.rx.switch.asDriver()
        
        openEnable
            .drive(onNext: enableView)
            .addDisposableTo(disposeBag)
        
        openEnable
            .drive(touchesBeganEnable)
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
        
        //let viewModel = SchoolTimeViewModel()
    }
    
    //
    /// MARK: -- Private
    //
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
        self.amStartTimeOutlet.isEnabled = false
        self.amEndTimeOutlet.isEnabled = true
        self.pmStartTimeOutlet.isEnabled = true
        self.pmEndTimeOutlet.isEnabled = true
        self.showTimePicker(time: self.amStartTimeOutlet.titleLabel?.text ?? "")
    }
    
    private func selectAmEndTime() {
        self.datepicke.minimumDate = self.amMin
        self.datepicke.maximumDate = self.amMax
        self.amStartTimeOutlet.isEnabled = true
        self.amEndTimeOutlet.isEnabled = false
        self.pmStartTimeOutlet.isEnabled = true
        self.pmEndTimeOutlet.isEnabled = true
        self.showTimePicker(time: self.amEndTimeOutlet.titleLabel?.text ?? "")
    }
    private func selectPmStartTime() {
        self.datepicke.minimumDate = self.pmMin
        self.datepicke.maximumDate = self.pmMax
        self.amStartTimeOutlet.isEnabled = true
        self.amEndTimeOutlet.isEnabled = true
        self.pmStartTimeOutlet.isEnabled = false
        self.pmEndTimeOutlet.isEnabled = true
        self.showTimePicker(time: self.pmStartTimeOutlet.titleLabel?.text ?? "")
    }
    private func selectPmEndTime() {
        self.datepicke.minimumDate = self.pmMin
        self.datepicke.maximumDate = self.pmMax
        self.amStartTimeOutlet.isEnabled = true
        self.amEndTimeOutlet.isEnabled = true
        self.pmStartTimeOutlet.isEnabled = true
        self.pmEndTimeOutlet.isEnabled = false
        self.showTimePicker(time: self.pmEndTimeOutlet.titleLabel?.text ?? "")
    }
    
    private func cancelDatepicker() {
        datePickView.isHidden = true
        amStartTimeOutlet.isEnabled = true
        amEndTimeOutlet.isEnabled = true
        pmStartTimeOutlet.isEnabled = true
    }
    
    private func comfirmDatepicker() {
        if !amStartTimeOutlet.isEnabled {
            amStartTimeOutlet.setTitle(self.showPickerTime(), for: .normal)
            amStartTimeOutlet.isEnabled = true
        }
        if !amEndTimeOutlet.isEnabled {
            amEndTimeOutlet.setTitle(self.showPickerTime(), for: .normal)
            amEndTimeOutlet.isEnabled = true
        }
        if !pmStartTimeOutlet.isEnabled {
            pmStartTimeOutlet.setTitle(self.showPickerTime(), for: .normal)
            pmStartTimeOutlet.isEnabled = true
        }
        if !pmEndTimeOutlet.isEnabled {
            pmEndTimeOutlet.setTitle(self.showPickerTime(), for: .normal)
            pmEndTimeOutlet.isEnabled = true
        }
        
        datePickView.isHidden = true
    }
    
    private func dateOtherFromSelected(date: Date) -> Bool {
        if !amStartTimeOutlet.isEnabled {
            let time = DateUtility.zoneDayOfHMS(
                date: DateUtility.date(from: amEndTimeOutlet.titleLabel?.text))
            let comp = time.compare(date)
            return (comp == .orderedDescending)
        }
        if !amEndTimeOutlet.isEnabled {
            let time = DateUtility.zoneDayOfHMS(
                date: DateUtility.date(from: amStartTimeOutlet.titleLabel?.text))
            let comp = time.compare(date)
            return comp == .orderedAscending
        }
        if !pmStartTimeOutlet.isEnabled {
            let time = DateUtility.zoneDayOfHMS(
                date: DateUtility.date(from: pmEndTimeOutlet.titleLabel?.text))
            let comp = time.compare(date)
            return comp == .orderedDescending
        }
        if !pmEndTimeOutlet.isEnabled {
            let time = DateUtility.zoneDayOfHMS(
                date: DateUtility.date(from: pmStartTimeOutlet.titleLabel?.text))
            let comp = time.compare(date)
            return comp == .orderedAscending
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touchesBeganEnable.value {
            datePickView.isHidden = true
            amStartTimeOutlet.isEnabled = true
            amEndTimeOutlet.isEnabled = true
            pmStartTimeOutlet.isEnabled = true
            pmEndTimeOutlet.isEnabled = true
        }
    }
    
   private func showPickerTime() -> String {
        let date = datepicke.date
        let dformatter = DateFormatter()
        dformatter.timeZone = TimeZone(secondsFromGMT: 0)
        dformatter.dateFormat = "HH:mm"
        let dateStr = dformatter.string(from: date)
        return dateStr
    }
    
    private func showTimePicker(time: String) {
        self.datePickView.isHidden = false
        self.datepicke.date = DateUtility.zoneDayOfHMS(
            date: DateUtility.date(from: time))
        Logger.info(self.datepicke.date)
    }
    
    
    private var amMin: Date {
        return DateUtility.zoneDay().startDate
    }
    
    private var amMax: Date {
        return DateUtility.zoneDay().startDate.addingTimeInterval(DateUtility.SEC_HDAY-1)
    }
    
    private var pmMin: Date {
        return DateUtility.zoneDay().startDate.addingTimeInterval(DateUtility.SEC_HDAY)
    }
    
    private var pmMax: Date {
        return DateUtility.zoneDay().endDate
    }
}

class DateUtility {
    
    static let SEC_DAY: TimeInterval = 24 * 60 * 60
    static let SEC_HDAY: TimeInterval = DateUtility.SEC_DAY * 0.5
    
    static func date(from text: String?) -> Date {
        guard let _text = text else {
            return Date(timeIntervalSince1970: 0)
        }
        let dformatter = DateFormatter()
        dformatter.timeZone = TimeZone(secondsFromGMT: 0)
        dformatter.dateFormat = "HH:mm"
        return dformatter.date(from: _text) ?? Date(timeIntervalSince1970: 0)
    }
    
    static func zoneDay() -> (startDate: Date, endDate: Date) {
        let now = Date(timeIntervalSince1970: 0)
        return (now,now.addingTimeInterval(DateUtility.SEC_DAY))
    }
    
    static func zoneDayOfHMS(date: Date) -> Date {
        return Date(timeIntervalSince1970: date.timeIntervalSince1970.truncatingRemainder(dividingBy: SEC_DAY))
    }
    
    func today() -> (startDate: Date, endDate: Date) {
        let calendar = Calendar.current
        let now = Date()
        var set = Set<Calendar.Component>()
        set.insert(.year)
        set.insert(.month)
        set.insert(.day)
        let components = calendar.dateComponents(set, from: now)
        let startDate = calendar.date(from: components)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate!)
        return (startDate!, endDate!)
    }
}

