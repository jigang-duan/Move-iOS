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
    
    let defaultProfile = (gender: Gender.male, birthday: Date(timeIntervalSince1970: 329846400), height: 170, weight: 70)
    
    var settingSaveBlock: ((Gender?, Int?, UnitType?, Int?, UnitType?, Date?, UIImage?) -> Void)?
    
    var gender: Gender?
    var height: Int?
    var weight: Int?
    var birthday: Date?
    
    var heightUnit:UnitType?
    var weightUnit:UnitType?
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoutBun: UIButton!
    
    var photoPicker: ImageUtility?
    var changedImage: UIImage?
    
    var headImgV: UIImageView!
    
    var disposeBag = DisposeBag()
    
    
    let activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
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
        self.title = R.string.localizable.id_button_menu_account()
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
        heightUnit = (info?.heightUnit == .british) ? .british:.metric
        weightUnit = (info?.weightUnit == .british) ? .british:.metric
    
        
        headImgV = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        headImgV.layer.cornerRadius = 15
        headImgV.layer.masksToBounds = true
        let placeImg = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: headImgV.frame.width, height: headImgV.frame.height), fullName: info?.nickname ?? "").imageRepresentation()!
        let imgUrl = URL(string: FSManager.imageUrl(with: info?.iconUrl ?? ""))
        headImgV.kf.setImage(with: imgUrl, placeholder: placeImg)
        
        
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
                if valid == false {
                    self.activity.startAnimating()
                }else{
                    self.activity.stopAnimating()
                }
            })
            .addDisposableTo(disposeBag)
        
        
        
        viewModel.logoutResult
            .drive(onNext: { [unowned self] result in
                switch result {
                case .failed:
                    self.showMessage("Logout failed")
                case .ok:
                    Distribution.shared.popToLoginScreen()
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)
        
        activity.center = self.view.center
        self.view.addSubview(activity)
        
    }
    
    
    func showMessage(_ text: String) {
        let vc = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: R.string.localizable.id_ok(), style: .cancel)
        vc.addAction(action)
        self.present(vc, animated: true)
    }
    
    
    func selectPhoto() {
        photoPicker = ImageUtility()
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let action1 = UIAlertAction(title: R.string.localizable.id_take_a_photo(), style: UIAlertActionStyle.default) { _ in
            self.photoPicker?.selectPhoto(with: self, soureType: .camera, size: CGSize(width: 100, height: 100), callback: { (image) in
                self.headImgV.image = image
                self.changedImage = image
            })
        }
        let action2 = UIAlertAction(title: R.string.localizable.id_select_image(), style: UIAlertActionStyle.default) { _ in
            self.photoPicker?.selectPhoto(with: self, soureType: .photoLibrary, size: CGSize(width: 100, height: 100), callback: { (image) in
                self.headImgV.image = image
                self.changedImage = image
            })
        }
        let action3 = UIAlertAction(title: R.string.localizable.id_cancel(), style: UIAlertActionStyle.cancel)
        
        vc.addAction(action1)
        vc.addAction(action2)
        vc.addAction(action3)
        
        if let popover = vc.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = headImgV.frame
        }
        
        self.present(vc, animated: true, completion: nil)
    }
    
    
}


extension MeSettingController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
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
            cell?.textLabel?.text = R.string.localizable.id_photo()
            var frame = headImgV.frame
            frame.origin.x = UIScreen.main.bounds.width - 70
            frame.origin.y = 9
            headImgV.frame = frame
            cell?.contentView.addSubview(headImgV)
            cell?.selectionStyle = .none
        case IndexPath(row: 1, section: 0):
            cell?.textLabel?.text = R.string.localizable.id_name()
            cell?.detailTextLabel?.text = info?.nickname
        case IndexPath(row: 2, section: 0):
            cell?.textLabel?.text =  R.string.localizable.id_email()
            cell?.detailTextLabel?.text = info?.email
        case IndexPath(row: 3, section: 0):
            cell?.textLabel?.text =  R.string.localizable.id_change_password()
            cell?.detailTextLabel?.text = "●●●●●●"
        case IndexPath(row: 0, section: 1):
            cell?.textLabel?.text = R.string.localizable.id_gender()
            if let g = gender {
                cell?.detailTextLabel?.text = (g == .female ? R.string.localizable.id_user_female():R.string.localizable.id_user_male())
            }else{
                cell?.detailTextLabel?.text = R.string.localizable.id_not_specified()
            }
        case IndexPath(row: 1, section: 1):
            cell?.textLabel?.text = R.string.localizable.id_height()
            if let h = height, h > 0 {
                cell?.detailTextLabel?.text = "\(h) " + ((heightUnit == UnitType.metric) ? "cm":"inch")
            }else{
                cell?.detailTextLabel?.text = R.string.localizable.id_not_specified()
            }
        case IndexPath(row: 2, section: 1):
            cell?.textLabel?.text = R.string.localizable.id_weight()
            if let w = weight, w > 0 {
                cell?.detailTextLabel?.text = "\(w) " + ((weightUnit == UnitType.metric) ? "kg":"lb")
            }else{
                cell?.detailTextLabel?.text = R.string.localizable.id_not_specified()
            }
        case IndexPath(row: 3, section: 1):
            cell?.textLabel?.text = R.string.localizable.id_birthday()
            if let b = birthday, b > Date(timeIntervalSince1970: -2209017600) {
                cell?.detailTextLabel?.text = b.stringYearMonthDay
            }else{
                cell?.detailTextLabel?.text = R.string.localizable.id_not_specified()
            }
        default:
            break
        }
        
        
        return cell!
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                self.selectPhoto()
            case 1:
                self.performSegue(withIdentifier: R.segue.meSettingController.showChangeName, sender: nil)
            case 3:
                self.performSegue(withIdentifier: R.segue.meSettingController.showChangePswd, sender: nil)
            default:
                ()
            }
        }
        
        if indexPath.section == 1{
            switch indexPath.row {
            case 0:
                let vc = R.storyboard.kidInformation.setYourGenderController()!
                vc.selectedGender = self.gender ?? defaultProfile.gender
                vc.genderBlock = { [weak self] gender in
                    self?.gender = gender
                    self?.tableView.reloadData()
                }
                self.present(vc, animated: true)
            case 1:
                let vc = R.storyboard.kidInformation.setYourHeghtController()!
                if let h = height, h > 0 {
                    vc.selectedHeight = h
                }else{
                    vc.selectedHeight = defaultProfile.height
                }
                vc.isUnitCm = self.heightUnit == .metric
                vc.heightBlock = { [weak self] height, unit in
                    self?.height = height
                    self?.heightUnit = unit
                    self?.tableView.reloadData()
                }
                self.present(vc, animated: true);
            case 2:
                let vc = R.storyboard.kidInformation.setYourWeightController()!
                if let w = weight, w > 0 {
                    vc.selectedWeight = w
                }else{
                    vc.selectedWeight = defaultProfile.weight
                }
                vc.isUnitKg = self.weightUnit == .metric
                vc.weightBlock = { [weak self] weight, unit in
                    self?.weight = weight
                    self?.weightUnit = unit
                    self?.tableView.reloadData()
                }
                self.present(vc, animated: true)
            case 3:
                let vc = R.storyboard.kidInformation.setYourBirthdayController()!
                if let b = birthday, b > Date(timeIntervalSince1970: -2209017600) {
                    vc.selectedDate = b
                }else{
                    vc.selectedDate = defaultProfile.birthday
                }
                vc.birthdayBlock = { [weak self] birthday in
                    self?.birthday = birthday
                    self?.tableView.reloadData()
                }
                self.present(vc, animated: true)
            default:
                break
            }
        }
    }

}
















