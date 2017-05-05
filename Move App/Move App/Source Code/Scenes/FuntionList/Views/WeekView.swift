//
//  WeekView.swift
//  Move App
//
//  Created by jiang.duan on 2017/2/24.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation

enum WeekType: Int {
    case sun = 801
    case mon = 802
    case tue = 803
    case wed = 804
    case thu = 805
    case fir = 806
    case sat = 807
}

class WeekView: UIView {
    
    @IBOutlet weak var delegate: WeekViewDelegate?
    
    private var _weekSelected: [Bool] = [false, false, false, false, false, false, false]
    
    var weekSelected: [Bool] {
        get {
            return _weekSelected
        }
        set(newVal) {
            if newVal.count < _weekSelected.count {
                for i in 0 ..< newVal.count {
                    _weekSelected[i] = newVal[i]
                }
                for i in newVal.count ..< _weekSelected.count {
                    _weekSelected[i] = false
                }
            } else {
                for i in 0 ..< _weekSelected.count {
                    _weekSelected[i] = newVal[i]
                }
            }
            for i in 0 ..< 7 {
                buttons[i].isSelected = _weekSelected[i]
            }
            for btn in buttons {
                btn.backgroundColor = btn.isSelected ? R.color.appColor.primary() : R.color.appColor.fourthlyText()
            }
        }
    }
    
    var isEnable: Bool = true {
        didSet {
            for btn in buttons {
                if isEnable {
                    btn.backgroundColor = btn.isSelected ? R.color.appColor.primary() : R.color.appColor.fourthlyText()
                } else {
                    btn.backgroundColor = R.color.appColor.fourthlyText()
                }
            }
            self.isUserInteractionEnabled = isEnable
        }
    }
    
    private var buttons: [UIButton] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let monButton = self.viewWithTag(WeekType.mon.rawValue) as? UIButton
        let tueButton = self.viewWithTag(WeekType.tue.rawValue) as? UIButton
        let wedButton = self.viewWithTag(WeekType.wed.rawValue) as? UIButton
        let thuButton = self.viewWithTag(WeekType.thu.rawValue) as? UIButton
        let firButton = self.viewWithTag(WeekType.fir.rawValue) as? UIButton
        let satButton = self.viewWithTag(WeekType.sat.rawValue) as? UIButton
        let sunButton = self.viewWithTag(WeekType.sun.rawValue) as? UIButton
        
        monButton?.setTitle(R.string.localizable.monday_short(), for: .normal)
        tueButton?.setTitle(R.string.localizable.tuesday_short(), for: .normal)
        wedButton?.setTitle(R.string.localizable.wednesday_short(), for: .normal)
        thuButton?.setTitle(R.string.localizable.thursday_short(), for: .normal)
        firButton?.setTitle(R.string.localizable.friday_short(), for: .normal)
        satButton?.setTitle(R.string.localizable.saturday_short(), for: .normal)
        sunButton?.setTitle(R.string.localizable.sunday_short(), for: .normal)
        
        buttons.append(sunButton!)
        buttons.append(monButton!)
        buttons.append(tueButton!)
        buttons.append(wedButton!)
        buttons.append(thuButton!)
        buttons.append(firButton!)
        buttons.append(satButton!)
        
        monButton?.addTarget(self, action: #selector(weekAction(_:)), for: .touchUpInside)
        tueButton?.addTarget(self, action: #selector(weekAction(_:)), for: .touchUpInside)
        wedButton?.addTarget(self, action: #selector(weekAction(_:)), for: .touchUpInside)
        thuButton?.addTarget(self, action: #selector(weekAction(_:)), for: .touchUpInside)
        firButton?.addTarget(self, action: #selector(weekAction(_:)), for: .touchUpInside)
        satButton?.addTarget(self, action: #selector(weekAction(_:)), for: .touchUpInside)
        sunButton?.addTarget(self, action: #selector(weekAction(_:)), for: .touchUpInside)
    }
    
    func weekAction(_ sender: UIButton) {
        if (sender.tag == 10){
             delegate?.weekViewDidSelected?(self, selecteds: weekSelected)
        return
        }
        let index = number(tag: WeekType(rawValue: sender.tag)!)
        weekSelected[index] = !sender.isSelected

        delegate?.weekViewDidSelected?(self, selecteds: weekSelected)
    }
    
    private func number(tag: WeekType) -> Int {
        return tag.rawValue - 801
    }
    
}

@objc
protocol WeekViewDelegate {
    @objc optional func weekViewDidSelected(_ sender: WeekView, selecteds: [Bool])
}
