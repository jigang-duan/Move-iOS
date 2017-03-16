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
    @IBOutlet weak var personalInformationQutlet: UIButton!
    
    @IBOutlet weak var unpairCell: UITableViewCell!
    
    let disposeBag = DisposeBag()
    //是否是管理员
    var isboss: Bool = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let deviceInfo = DeviceManager.shared.currentDevice
        
        let placeImg = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: headQutlet.frame.width, height: headQutlet.frame.height), fullName: deviceInfo?.user?.nickname ?? "").imageRepresentation()!
     
        headQutlet.imageFromURL(deviceInfo?.user?.profile ?? "", placeholder: placeImg)
        
        accountNameQutlet.text = deviceInfo?.user?.nickname
        
    }

    @IBOutlet weak var aaa: UINavigationItem!
    @IBOutlet weak var autoAnswerQutel: SwitchButton!
    
    @IBOutlet weak var savePowerQutel: SwitchButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        personalInformationQutlet.rx.tap.bindNext { _ in
            let vc = R.storyboard.kidInformation.kidInformationController()!
            vc.isForSetting = true
            let kidInfo = DeviceManager.shared.currentDevice?.user
            var info = DeviceBindInfo()
            info.nickName = kidInfo?.nickname
            info.number = kidInfo?.number
            info.gender = kidInfo?.gender
            info.height = kidInfo?.height
            info.weight = kidInfo?.weight
            info.birthday = kidInfo?.birthday
            info.profile = kidInfo?.profile
            
            vc.deviceAddInfo = info
            self.navigationController?.show(vc, sender: nil)
        }
        .addDisposableTo(disposeBag)
    }
    
    func userInteractionEnabled(enable: Bool) {
       
    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        if isboss{
            return 2
        }else
        {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if unpairCell == tableView.cellForRow(at: indexPath) {
            let manager = DeviceManager.shared
            _ = manager.deleteDevice(with: (manager.currentDevice?.deviceId)!).subscribe({ event in
                switch event {
                case .next(let e):
                    if e {
                       _ = self.navigationController?.popToRootViewController(animated: true)
                    }
                case .completed:
                    break
                case .error(let er):
                    print(er)
                }
            })
        }
    }
    
    
}
















