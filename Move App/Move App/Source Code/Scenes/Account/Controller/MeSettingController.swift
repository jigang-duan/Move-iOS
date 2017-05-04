//
//  MeSettingController.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/9.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import CustomViews

class MeSettingController: UITableViewController {
    
    var settingSaveBlock: ((String?, Int?, UnitType?, Int?, UnitType?, Date?, UIImage?) -> Void)?
    
    var gender: String?
    var height: Int?
    var weight: Int?
    var birthday: Date?
    
    var heightUnit:UnitType?
    var weightUnit:UnitType?
    
    @IBOutlet weak var headBun: UIButton!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var emailLab: UILabel!
    
    @IBOutlet weak var genderLab: UILabel!
    @IBOutlet weak var heightLab: UILabel!
    @IBOutlet weak var weightLab: UILabel! 
    @IBOutlet weak var birthdayLab: UILabel!
    
    
    
    @IBOutlet var settingCells: [UITableViewCell]!
    
    
    var photoPicker: ImageUtility?
    var changedImage: UIImage?
    
    
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
                || birthday != info?.birthday
                || changedImage != nil {
                self.settingSaveBlock!(gender, height, heightUnit, weight, weightUnit, birthday, changedImage)
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
        
        if let gender = info?.gender {
            genderLab.text = (gender == "0" ? "male":"female")
        }else{
            genderLab.text = "Not specified"
        }
        
        if let height = info?.height {
            heightLab.text = "\(height) " + ((info?.heightUnit == UnitType.metric) ? "cm":"inch")
        }else{
            heightLab.text = "Not specified"
        }
        
        if let weight = info?.weight {
            weightLab.text = "\(weight) " + ((info?.weightUnit == UnitType.metric) ? "kg":"lb")
        }else{
            weightLab.text = "Not specified"
        }
        
        if let birthday = info?.birthday, birthday != Date(timeIntervalSince1970: 0) {
            birthdayLab.text = birthday.stringYearMonthDay
        }else{
            birthdayLab.text = "Not specified"
        }
        
        let placeImg = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: headBun.frame.width, height: headBun.frame.height), fullName: info?.nickname ?? "").imageRepresentation()!
        
        let imgUrl = URL(string: FSManager.imageUrl(with: info?.iconUrl ?? ""))
        headBun.kf.setBackgroundImage(with: imgUrl, for: .normal, placeholder: placeImg)
    }
    
    @IBAction func selectPhoto(_ sender: UIButton) {
        photoPicker = ImageUtility()
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let action1 = UIAlertAction(title: "PhotoLibrary", style: UIAlertActionStyle.default) { _ in
            self.photoPicker?.selectPhoto(with: self, soureType: .photoLibrary, size: CGSize(width: 100, height: 100), callback: { (image) in
                self.headBun.setBackgroundImage(image, for: .normal)
                self.changedImage = image
            })
        }
        let action2 = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default) { _ in
            self.photoPicker?.selectPhoto(with: self, soureType: .camera, size: CGSize(width: 100, height: 100), callback: { (image) in
                self.headBun.setBackgroundImage(image, for: .normal)
                self.changedImage = image
            })
        }
        let action3 = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        
        vc.addAction(action1)
        vc.addAction(action2)
        vc.addAction(action3)
        
        if let popover = vc.popoverPresentationController {
            popover.sourceView = sender.superview
            popover.sourceRect = sender.frame
        }
        
        self.present(vc, animated: true, completion: nil)
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
                self.present(vc, animated: true)
            case 1:
                let vc = R.storyboard.kidInformation.setYourHeghtController()!
                vc.selectedHeight = self.height ?? 160
                vc.isUnitCm = (self.heightUnit == .metric) ? true:false
                vc.heightBlock = { height, unit in
                    self.height = height
                    self.heightUnit = unit
                    self.heightLab.text = "\(height) " + ((unit == UnitType.metric) ? "cm":"inch")
                }
                self.present(vc, animated: true);
            case 2:
                let vc = R.storyboard.kidInformation.setYourWeightController()!
                vc.selectedWeight = self.weight ?? 70
                vc.isUnitKg = (self.weightUnit == .metric) ? true:false
                vc.weightBlock = {weight, unit in
                    self.weight = weight
                    self.weightUnit = unit
                    self.weightLab.text = "\(weight) " + ((unit == UnitType.metric) ? "kg":"lb")
                }
                self.present(vc, animated: true)
            case 3:
                let vc = R.storyboard.kidInformation.setYourBirthdayController()!
                vc.birthdayBlock = {birthday in
                    self.birthday = birthday
                    self.birthdayLab.text = birthday.stringYearMonthDay
                }
                self.present(vc, animated: true)
            default:
                break
            }
        }
    }
    
    
    
}
