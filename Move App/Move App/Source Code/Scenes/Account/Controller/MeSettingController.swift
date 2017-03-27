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
    
    var settingSaveBlock: ((String?, Int?, Int?, Date?, UIImage?) -> Void)?
    
    var gender: String?
    var height: Int?
    var weight: Int?
    var birthday: Date?
    
    
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
                self.settingSaveBlock!(gender, height, weight, birthday, changedImage)
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
        
        let placeImg = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: headBun.frame.width, height: headBun.frame.height), fullName: info?.nickname ?? "").imageRepresentation()!
        
        let imgUrl = URL(string: FSManager.imageUrl(with: info?.iconUrl ?? ""))
        headBun.kf.setBackgroundImage(with: imgUrl, for: .normal, placeholder: placeImg)
    }
    
    @IBAction func selectPhoto(_ sender: Any) {
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
