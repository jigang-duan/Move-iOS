//
//  MeSettingController.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/9.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import CustomViews
import RxSwift
import RxCocoa

class MeSettingController: UIViewController {
    
    var settingSaveBlock: ((String?, Int?, UnitType?, Int?, UnitType?, Date?, UIImage?) -> Void)?
    
    var gender: String?
    var height: Int?
    var weight: Int?
    var birthday: Date?
    
    var heightUnit:UnitType?
    var weightUnit:UnitType?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headBun: UIButton!
    @IBOutlet weak var logoutBun: UIButton!
    
    var photoPicker: ImageUtility?
    var changedImage: UIImage?
    
    
    var disposeBag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
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
    
    private func initializeI18N() {
        self.title = R.string.localizable.id_me()
        logoutBun.setTitle(R.string.localizable.id_login_out(), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeI18N()
        
        self.tableView.delegate = self
        
        let info = UserInfo.shared.profile
      
        gender = info?.gender
        height = info?.height
        weight = info?.weight
        birthday = info?.birthday
        heightUnit = info?.heightUnit
        weightUnit = info?.weightUnit
        
    
        
        let placeImg = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: headBun.frame.width, height: headBun.frame.height), fullName: info?.nickname ?? "").imageRepresentation()!
        
        let imgUrl = URL(string: FSManager.imageUrl(with: info?.iconUrl ?? ""))
        headBun.kf.setBackgroundImage(with: imgUrl, for: .normal, placeholder: placeImg)
        
        
    
        
        let viewModel = MeLogoutViewModel(
            input: logoutBun.rx.tap.asDriver(),
            dependency: (
                userManager: UserManager.shared,
                wireframe: DefaultWireframe.sharedInstance
        ))
        
        viewModel.logoutEnabled
            .drive(onNext: { [unowned self] valid in
                self.logoutBun.isEnabled = valid
                self.logoutBun.backgroundColor?.withAlphaComponent(valid ? 1.0 : 0.5)
            })
            .addDisposableTo(disposeBag)
        
        
        
        viewModel.logoutResult
            .drive(onNext: { [unowned self] result in
                switch result {
                case .failed(let message):
                    self.showMessage(message)
                case .ok:
                    UserInfo.shared.invalidate()
                    UserInfo.shared.profile = nil
                    Distribution.shared.popToLoginScreen()
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)
        
        
        
    }
    
    
    func showMessage(_ text: String) {
        let vc = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        vc.addAction(action)
        self.present(vc, animated: true)
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
    
    
}


extension MeSettingController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }else {
            return 4
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
            cell?.accessoryType = .disclosureIndicator
        }
        
        
        let info = UserInfo.shared.profile
        
        switch indexPath {
        case IndexPath(row: 0, section: 0):
            cell?.textLabel?.text = R.string.localizable.id_name()
            cell?.detailTextLabel?.text = info?.nickname
        case IndexPath(row: 1, section: 0):
            cell?.textLabel?.text =  R.string.localizable.id_email()
            cell?.detailTextLabel?.text = info?.email
        case IndexPath(row: 2, section: 0):
            cell?.textLabel?.text =  R.string.localizable.id_change_password()
            cell?.detailTextLabel?.text = "●●●●●●"
        case IndexPath(row: 0, section: 1):
            cell?.textLabel?.text = R.string.localizable.id_gender()
            if let g = gender, g.characters.count > 0 {
                cell?.detailTextLabel?.text = (g == "0" ? "male":"female")
            }else{
                cell?.detailTextLabel?.text = "Not specified"
            }
        case IndexPath(row: 1, section: 1):
            cell?.textLabel?.text = R.string.localizable.id_height()
            if let h = height, h > 0 {
                cell?.detailTextLabel?.text = "\(h) " + ((heightUnit == UnitType.metric) ? "cm":"inch")
            }else{
                cell?.detailTextLabel?.text = "Not specified"
            }
        case IndexPath(row: 2, section: 1):
            cell?.textLabel?.text = R.string.localizable.id_weight()
            if let w = weight, w > 0 {
                cell?.detailTextLabel?.text = "\(w) " + ((weightUnit == UnitType.metric) ? "kg":"lb")
            }else{
                cell?.detailTextLabel?.text = "Not specified"
            }
        case IndexPath(row: 3, section: 1):
            cell?.textLabel?.text = R.string.localizable.id_birthday()
            if let b = birthday, b > Date(timeIntervalSince1970: -2209017600) {
                cell?.detailTextLabel?.text = b.stringYearMonthDay
            }else{
                cell?.detailTextLabel?.text = "Not specified"
            }
        default:
            break
        }
        
        
        return cell!
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                self.performSegue(withIdentifier: R.segue.meSettingController.showChangeName, sender: nil)
            }
            if indexPath.row == 2 {
                self.performSegue(withIdentifier: R.segue.meSettingController.showChangePswd, sender: nil)
            }
        }
        
        if indexPath.section == 1{
            switch indexPath.row {
            case 0:
                let vc = R.storyboard.kidInformation.setYourGenderController()!
                vc.genderBlock = { gender in
                    self.gender = gender
                    self.tableView.reloadData()
                }
                self.present(vc, animated: true)
            case 1:
                let vc = R.storyboard.kidInformation.setYourHeghtController()!
                vc.selectedHeight = self.height ?? 160
                vc.isUnitCm = (self.heightUnit == .metric) ? true:false
                vc.heightBlock = { height, unit in
                    self.height = height
                    self.heightUnit = unit
                    self.tableView.reloadData()
                }
                self.present(vc, animated: true);
            case 2:
                let vc = R.storyboard.kidInformation.setYourWeightController()!
                vc.selectedWeight = self.weight ?? 70
                vc.isUnitKg = (self.weightUnit == .metric) ? true:false
                vc.weightBlock = {weight, unit in
                    self.weight = weight
                    self.weightUnit = unit
                    self.tableView.reloadData()
                }
                self.present(vc, animated: true)
            case 3:
                let vc = R.storyboard.kidInformation.setYourBirthdayController()!
                vc.birthdayBlock = {birthday in
                    self.birthday = birthday
                    self.tableView.reloadData()
                }
                self.present(vc, animated: true)
            default:
                break
            }
        }
    }

}
















