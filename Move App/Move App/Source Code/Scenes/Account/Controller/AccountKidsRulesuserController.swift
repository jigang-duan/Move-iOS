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
    
    @IBOutlet weak var autoAnswerQutel: SwitchButton!
    @IBOutlet weak var savePowerQutel: SwitchButton!
    
    let disposeBag = DisposeBag()
    
    
    
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
        _ = DeviceManager.shared.getContacts(deviceId: (DeviceManager.shared.currentDevice?.deviceId)!).subscribe({ (event) in
            switch event {
            case .next(let cons):
                for con in cons {
                    if con.admin == true {
                        if UserInfo.shared.id == con.uid {
                            //todo
                        }
                    }
                }
            case .completed:
                break
            case .error(let er):
                print(er)
            }
        })
        
    }
    
    func userInteractionEnabled(enable: Bool) {
       
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = R.segue.accountKidsRulesuserController.showUnpairTip(segue: segue)?.destination {
            vc.unpairBlock = { flag, message in
                if flag {
                    _ = self.navigationController?.popToRootViewController(animated: true)
                }else{
                    self.showMessage(message)
                }
            }
        }
        
        
        if let vc = R.segue.accountKidsRulesuserController.showKidInfomation(segue: segue)?.destination {
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
        }
    }
    
    func showMessage(_ text: String) {
        let vc = UIAlertController.init(title: "提示", message: text, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        vc.addAction(action)
        self.present(vc, animated: true) {
            
        }
    }
    
}
















