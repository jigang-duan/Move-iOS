//
//  AccountKidsRulesuserController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/21.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CustomViews


class AccountKidsRulesuserController: UITableViewController {
    
    @IBOutlet weak var watchContactCell: UITableViewCell!
    //internationalization
    @IBOutlet weak var kidswatchTitleItem: UINavigationItem!
    @IBOutlet weak var watchContactLabel: UILabel!
    @IBOutlet weak var safeZoneLabel: UILabel!
    @IBOutlet weak var schoolTimeLabel: UILabel!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var regularShutdownLabel: UILabel!
    @IBOutlet weak var unpairedwithWatchLabel: UILabel!
    @IBOutlet weak var unpairedwithwatchIntroduceLabel: UILabel!
    @IBOutlet weak var savepowerLabel: UILabel!
    @IBOutlet weak var savepowerIntroduceLabel: UILabel!
    @IBOutlet weak var usePermissiorLabel: UILabel!
    @IBOutlet weak var timeZoneLabel: UILabel!
    @IBOutlet weak var languageforthiswatchLabel: UILabel!
    @IBOutlet weak var apnLabel: UILabel!
    @IBOutlet weak var updateLabel: UILabel!
    @IBOutlet weak var unpairedWithLabel: UILabel!
    

    
//------------------------------------------------------------------------------------------------------
    
    @IBOutlet weak var headQutlet: UIImageView!
    @IBOutlet weak var accountNameQutlet: UILabel!
    
    @IBOutlet weak var autoAnswerQutel: SwitchButton!
    @IBOutlet weak var savePowerQutel: SwitchButton!
    
    
    var isAdminBool : Bool = false
    
    let disposeBag = DisposeBag()
    
    func internationalization() {
        //判断用户，没有多语言字串
        //kidswatchTitleItem.title =
        
        watchContactLabel.text = R.string.localizable.watch_contact()
        safeZoneLabel.text = R.string.localizable.safe_zone()
        schoolTimeLabel.text = R.string.localizable.school_time()
        reminderLabel.text = R.string.localizable.reminder()
        regularShutdownLabel.text = R.string.localizable.reminder()
        regularShutdownLabel.text = R.string.localizable.regular_shutdown()
        unpairedwithWatchLabel.text = R.string.localizable.auto_answer_call()
        unpairedwithwatchIntroduceLabel.text = R.string.localizable.auto_answer_call_describe()
        savepowerLabel.text = R.string.localizable.save_power()
        savepowerIntroduceLabel.text = R.string.localizable.save_power_describe()
        timeZoneLabel.text = R.string.localizable.time_zone()
        languageforthiswatchLabel.text = R.string.localizable.language_for_watch()
        apnLabel.text = R.string.localizable.apn()
        updateLabel.text = R.string.localizable.update()
        unpairedWithLabel.text = R.string.localizable.unpaired_with_watch()
      
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let deviceInfo = DeviceManager.shared.currentDevice
        
        let placeImg = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: headQutlet.frame.width, height: headQutlet.frame.height), fullName: deviceInfo?.user?.nickname ?? "").imageRepresentation()!
     
        let imgUrl = URL(string: FSManager.imageUrl(with: deviceInfo?.user?.profile ?? ""))
        headQutlet.kf.setImage(with: imgUrl, placeholder: placeImg)
        
        accountNameQutlet.text = deviceInfo?.user?.nickname
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //国际化R.string.localizable
       self.internationalization()
        
        let viewModel = AccountKidsRulesuserViewModel(
        input: (
            savePower: savePowerQutel.rx.value.asDriver(),
            autoAnswer: autoAnswerQutel.rx.value.asDriver()
        ),
        dependency: (
            settingsManager: WatchSettingsManager.share,
            validation: DefaultValidation.shared,
            wireframe: DefaultWireframe.sharedInstance
        )
        )
        
        viewModel.saveFinish
            .drive(onNext:{_ in
            }).addDisposableTo(disposeBag)
        
        viewModel.savePowerEnable.drive(savePowerQutel.rx.on).addDisposableTo(disposeBag)
        viewModel.autoAnswereEnable.drive(autoAnswerQutel.rx.on).addDisposableTo(disposeBag)
        
        viewModel.activityIn
            .map({ !$0 })
            .drive(onNext: userInteractionEnabled)
            .addDisposableTo(disposeBag)
        
        //        判断当前是否是管理员
        DeviceManager.shared.getContacts(deviceId: (DeviceManager.shared.currentDevice?.deviceId)!).subscribe({ (event) in
            switch event {
            case .next(let cons):
                for con in cons {
                    if con.admin == true {
                        UserInfo.shared.id == con.uid ? (self.isAdminBool = true) : (self.isAdminBool = false)
                        self.tableView.reloadData()
                    }
                }
            case .completed:
                break
            case .error(let er):
                print(er)
            }
        }).addDisposableTo(disposeBag)

        
        
    }
    
    func userInteractionEnabled(enable: Bool) {
       
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //unpair
        if let vc = R.segue.accountKidsRulesuserController.showUnpairTip(segue: segue)?.destination {
            vc.isMaster = self.isAdminBool
            vc.unpairBlock = { flag, message in
                if flag {
                    _ = self.navigationController?.popToRootViewController(animated: true)
                }else{
                    self.showMessage(message)
                }
            }
        }
        //apn
        if let vc = R.segue.accountKidsRulesuserController.showApn(segue: segue)?.destination {
            vc.hasPairedWatch = true
            vc.imei = RxStore.shared.currentDeviceId.value!
        }
        //infomation
        if let vc = R.segue.accountKidsRulesuserController.showKidInfomation(segue: segue)?.destination {
            vc.isForSetting = true
            let kidInfo = DeviceManager.shared.currentDevice?.user
            var info = DeviceBindInfo()
            info.nickName = kidInfo?.nickname
            info.number = kidInfo?.number
            info.gender = kidInfo?.gender
            info.height = kidInfo?.height
            info.weight = kidInfo?.weight
            info.heightUnit = kidInfo?.heightUnit
            info.weightUnit = kidInfo?.weightUnit
            info.birthday = kidInfo?.birthday
            info.profile = kidInfo?.profile
            
            vc.addInfoVariable.value = info
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell == watchContactCell {
            if isAdminBool == true {
                let vc = R.storyboard.contact().instantiateInitialViewController()
                self.navigationController?.show(vc!, sender: nil)
            }else{
                let vc = R.storyboard.contact.familyMemberController()!
                vc.isMater = false
                self.navigationController?.show(vc, sender: nil)
            }
        }
    }
    
    
    
    func showMessage(_ text: String) {
        let vc = UIAlertController(title: "提示", message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        vc.addAction(action)
        self.present(vc, animated: true)
    }
    
   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if isAdminBool{
    if indexPath.section == 0{
        return 55}
    else if indexPath.section == 1{
        return 44}
    else{
        if ((indexPath.row == 0) || (indexPath.row == 1)){
            return 95}
    else{
            return 44}
    }
    }else
    {
        if indexPath.section == 0 {
            return 55
        }else if indexPath.section == 1 {
            if indexPath.row == 4 {
                return 0
            }else{
                return 44
            }
        }else{
            if indexPath.row == 7 {
                return 44
            }else{
                return 0
            }
        }

    }
}
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return R.string.localizable.function()
        }
        else if (section == 2){
            return R.string.localizable.action_settings()
        }else{
            return ""
        }
    }
    
}
















