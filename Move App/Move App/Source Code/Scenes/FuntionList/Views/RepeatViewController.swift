//
//  RepeatViewController.swift
//  Move App
//
//  Created by LX on 2017/3/9.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit


enum RepeatCount: Int{
    case never  = 0
    case day    = 1
    case week   = 2
    case month  = 3
    
    func description() -> String {
        switch self {
        case .never:
            return R.string.localizable.id_never()
        case .day:
            return R.string.localizable.id_everyday()
        case .week:
            return R.string.localizable.id_everyweek()
        case .month:
            return R.string.localizable.id_everymonth()
        }
    }
}


class RepeatViewController: UITableViewController {
     //internationalization
    @IBOutlet weak var NeverLabel: UILabel!
    @IBOutlet weak var everydayLabel: UILabel!
    @IBOutlet weak var everyweekhLabel: UILabel!
    @IBOutlet weak var everymonthLabel: UILabel!
    

    @IBOutlet weak var nevercell: UITableViewCell!
    @IBOutlet weak var everydaycell: UITableViewCell!
    @IBOutlet weak var everyweekcell: UITableViewCell!
    @IBOutlet weak var everymonthcell: UITableViewCell!
    
    var repeatBlock: ((RepeatCount) -> Void)?
    var selectedRepeat: RepeatCount?
    
    private func internationalization() {
        self.title = R.string.localizable.id_setting_my_clock_repeat()
        NeverLabel.text = R.string.localizable.id_never()
        everydayLabel.text = R.string.localizable.id_everyday()
        everyweekhLabel.text = R.string.localizable.id_everyweek()
        everymonthLabel.text = R.string.localizable.id_everymonth()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.internationalization()
        
        switch selectedRepeat ?? .never {
        case .never:
            nevercell?.accessoryType = .checkmark
        case .day:
            everydaycell?.accessoryType = .checkmark
        case .week:
            everyweekcell?.accessoryType = .checkmark
        case .month:
            everymonthcell?.accessoryType = .checkmark
        }
    }

}

extension RepeatViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        nevercell?.accessoryType = .none
        everydaycell?.accessoryType = .none
        everyweekcell?.accessoryType = .none
        everymonthcell?.accessoryType = .none
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        
        if repeatBlock != nil {
            self.repeatBlock!(RepeatCount(rawValue: indexPath.row)!)
        }
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }

}
