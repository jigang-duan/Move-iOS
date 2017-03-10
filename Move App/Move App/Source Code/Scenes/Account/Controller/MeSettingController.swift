//
//  MeSettingController.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/9.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class MeSettingController: UITableViewController {
    
    var settingSaveBlock: ((String?, Int?, Int?, Date?) -> Void)?
    
    var gender: String?
    var height: Int?
    var weight: Int?
    var birthday: Date?
    
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var emailLab: UILabel!
    
    @IBOutlet weak var genderLab: UILabel!
    @IBOutlet weak var heightLab: UILabel!
    @IBOutlet weak var weightLab: UILabel! 
    @IBOutlet weak var birthdayLab: UILabel!
    
    
    
    @IBOutlet var settingCells: [UITableViewCell]!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let info = UserInfo.shared.profile
        name.text = info?.nickname
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.settingSaveBlock != nil {
            let info = UserInfo.shared.profile
            if gender != info?.gender
                || height != info?.height
                || weight != info?.weight
                || birthday != info?.birthday {
                self.settingSaveBlock!(gender, height, weight, birthday)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let info = UserInfo.shared.profile
      
        gender = info?.gender
        height = info?.height
        weight = info?.weight
        birthday = info?.birthday
        
        emailLab.text = info?.email
        genderLab.text = info?.gender
        heightLab.text = String(info?.height ?? 0)
        weightLab.text = String(info?.weight ?? 0)
        birthdayLab.text = info?.birthday?.stringYearMonthDay
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let index = settingCells.index(of: cell!) {
            switch index {
            case 0:
                let vc = R.storyboard.kidInformation.setYourGenderController()!
                vc.genderBlock = { gender in
                    self.gender = gender
                    self.genderLab.text = gender
                }
                self.present(vc, animated: true, completion: {
                    
                })
            case 1:
                let vc = R.storyboard.kidInformation.setYourHeghtController()!
                vc.heightBlock = { height in
                    self.height = height
                    self.heightLab.text = String(height)
                }
                self.present(vc, animated: true, completion: {
                    
                })
            case 2:
                let vc = R.storyboard.kidInformation.setYourWeightController()!
                vc.weightBlock = {weight in
                    self.weight = weight
                    self.weightLab.text = String(weight)
                }
                self.present(vc, animated: true, completion: {
                    
                })
            case 3:
                let vc = R.storyboard.kidInformation.setYourBirthdayController()!
                vc.birthdayBlock = {birthday in
                    self.birthday = birthday
                    self.birthdayLab.text = birthday.stringYearMonthDay
                }
                self.present(vc, animated: true, completion: {
                    
                })
            default:
                break
            }
        }
    }
    
    
    
}
