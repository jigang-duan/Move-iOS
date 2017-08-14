//
//  RemindersCell.swift
//  Move App
//
//  Created by LX on 2017/3/13.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import CustomViews
import RxSwift

protocol RemindersCellDelegate {
    func switchDid(cell: RemindersCell, model: KidSetting.Reminder.Alarm)
}

class RemindersCell: UITableViewCell {
    var delegate: RemindersCellDelegate?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailtitleLabel: UILabel!
    @IBOutlet weak var accviewBtn: SwitchButton!
    var disposeBag = DisposeBag()
    
    var model: KidSetting.Reminder.Alarm? {
        didSet  {
            titleLabel.text = DateUtility.dateTostringHHmm(date: model?.alarmAt)
            detailtitleLabel.text = timeToType(repeatDays: (model?.day ?? [false,false,false,false,false,false,false])!)
            accviewBtn.isHidden = false
            accviewBtn.isOn = model?.active ?? false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        accviewBtn.closureSwitch = { [unowned self] isOn in
            if let model = self.model {
                self.delegate?.switchDid(cell: self, model: model)
                
                 _ = KidSettingsManager.shared.updateAlarm(model, new: KidSetting.Reminder.Alarm(alarmAt:model.alarmAt, day: model.day, active: isOn))
                    .subscribe(onNext:{ _ in
                        
                    })
                    .addDisposableTo(self.disposeBag)
            }
        }
    }

    func timeToType(repeatDays : [Bool]) -> String {
        let week : [String] = [R.string.localizable.id_week_sunday(),
                               R.string.localizable.id_week_monday(),
                               R.string.localizable.id_week_tuesday(),
                               R.string.localizable.id_week_wednesday(),
                               R.string.localizable.id_week_thurday(),
                               R.string.localizable.id_week_friday(),
                               R.string.localizable.id_week_saturday()
                              ]
        
        if repeatDays.contains(false) == false {
            return R.string.localizable.id_week_everyday()
        }
        
        if repeatDays == [false,true,true,true,true,true,false] {
            return R.string.localizable.id_week_school_day()
        }
        
        if repeatDays == [true,false,false,false,false,false,true] {
            return R.string.localizable.id_week_weekend()
        }
        
        var s = ""
        for index in 0..<repeatDays.count {
            if repeatDays[index] == true {
                s += week[index] + " "
            }
        }
        
        return s == "" ? R.string.localizable.id_week_no_repeat():s
    }

    
}
