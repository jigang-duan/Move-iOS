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

    @IBOutlet weak var headQutlet: UIImageView!
    @IBOutlet weak var accountNameQutlet: UILabel!
    @IBOutlet weak var personalInformationQutlet: UIButton!
    
    @IBOutlet weak var unpairCell: UITableViewCell!
    
    let disposeBag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let deviceInfo = DeviceManager.shared.currentDevice
        
        let placeImg = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: headQutlet.frame.width, height: headQutlet.frame.height), fullName: deviceInfo?.user?.nickname ?? "").imageRepresentation()!
     
        headQutlet.imageFromURL(deviceInfo?.user?.profile ?? "", placeholder: placeImg)
        
        accountNameQutlet.text = deviceInfo?.user?.nickname
        
    }

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
            vc.isForSetting = Variable(true)
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
















