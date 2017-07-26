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
    func switchDid(cell: RemindersCell, model: NSDictionary)
}


class RemindersCell: UITableViewCell {
    
    var delegate: RemindersCellDelegate?
    
   
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailtitleLabel: UILabel!
    @IBOutlet weak var accviewBtn: SwitchButton!
    var disposeBag = DisposeBag()
    
    var model: NSDictionary? = nil {
        didSet  {
            titleLabel.text = DateUtility.dateTostringHHmm(date: model?["alarms"] as? Date)
            detailtitleLabel.text = timeToType(weeks: model?["dayFromWeek"] as! [Bool])
            accviewBtn.isHidden = false
            accviewBtn.isOn = model?["active"] as! Bool
        }
    
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        accviewBtn.closureSwitch = { [unowned self] isOn in
            if let model = self.model {
                
                //把vomdel 的所有信息导，和isOn
                let vmodel = model
                print(isOn)
                print(vmodel)
                self.delegate?.switchDid(cell: self, model: vmodel)
                let _ = KidSettingsManager.shared.updateAlarm(KidSetting.Reminder.Alarm(alarmAt: (vmodel["alarms"] as? Date ?? nil)!, day: (vmodel["dayFromWeek"] as? [Bool])!, active: vmodel["active"] as? Bool), new: KidSetting.Reminder.Alarm(alarmAt: (vmodel["alarms"] as? Date ?? nil)!, day: (vmodel["dayFromWeek"] as? [Bool])!, active: isOn))
                    .subscribe(onNext:
                        {
                            print($0)
                            if $0 {
                                
                            }else{
                                
                            }
                    }).addDisposableTo(self.disposeBag)
            }
        }
    }

    func timeToType(weeks : [Bool]) -> String {
        // 7 tian , every day ,schooltime
        let week : [String] = [R.string.localizable.id_week_sunday(),R.string.localizable.id_week_monday(),R.string.localizable.id_week_tuesday(),R.string.localizable.id_week_wednesday(),R.string.localizable.id_week_thurday(),R.string.localizable.id_week_friday(),R.string.localizable.id_week_saturday(),R.string.localizable.id_week_everyday(),R.string.localizable.id_week_school_day()]
        var s : String = ""
        var weekss = weeks
//        weekss.insert(weeks.last!, at: 0)
        for index in 0 ... 6{
            if weekss[index]{
                s += week[index]
                s += " "
            }
        }
        if s == R.string.localizable.id_week_monday()+" "+R.string.localizable.id_week_tuesday()+" "+R.string.localizable.id_week_wednesday()+" "+R.string.localizable.id_week_thurday()+" "+R.string.localizable.id_week_friday()+" "
        {
            s = R.string.localizable.id_week_school_day()
        }
       else if s == R.string.localizable.id_week_sunday()+" "+R.string.localizable.id_week_monday()+" "+R.string.localizable.id_week_tuesday()+" "+R.string.localizable.id_week_wednesday()+" "+R.string.localizable.id_week_thurday()+R.string.localizable.id_week_friday()+" "+R.string.localizable.id_week_saturday()+" "
            
        {
            s = R.string.localizable.id_week_everyday()
        }
       else if s == R.string.localizable.id_week_sunday()+" "+R.string.localizable.id_week_saturday()+" "
        {
            s = R.string.localizable.id_week_weekend()
        }
       else if s == ""
        {
            s = R.string.localizable.id_week_no_repeat()
        }
        return s
    }

    
}
