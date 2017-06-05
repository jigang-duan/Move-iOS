//
//  AccountAndChoseDeviceController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/21.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxOptional
import CustomViews
import Kingfisher


class AccountAndChoseDeviceController: UIViewController {

    @IBOutlet weak var headOutlet: UIImageView!
    @IBOutlet weak var accountNameOutlet: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var personalInformationLab: UILabel!
    @IBOutlet weak var deviceLab: UILabel!
    @IBOutlet weak var addDeviceLab: UILabel!
    
    
    
    let disposeBag = DisposeBag()
    let enterSubject = PublishSubject<Bool>()
    
    
    private func initializeI18N() {
        self.title = R.string.localizable.id_me()
        personalInformationLab.text = R.string.localizable.id_account_inform()
        deviceLab.text = R.string.localizable.id_device()
        addDeviceLab.text = R.string.localizable.id_add_device()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initializeI18N()
        
        let viewModel = AccountAndChoseDeviceViewModel(
            input: (
                enter: enterSubject.asDriver(onErrorJustReturn: false),
                empty: Void()
            ),
            dependency:(
                userManager: UserManager.shared,
                deviceManager: DeviceManager.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        tableView.rx.setDelegate(self).addDisposableTo(disposeBag)
        
        viewModel.fetchDevices.drive(RxStore.shared.deviceInfosState).addDisposableTo(disposeBag)
        
        RxStore.shared.deviceInfosObservable
            .bindTo(tableView.rx.items(cellIdentifier: R.reuseIdentifier.cellDevice.identifier)) { (row, device, cell) in
                cell.textLabel?.text = device.deviceType?.description
                cell.detailTextLabel?.text = device.user?.nickname
                cell.imageView?.image = device.deviceType?.image
            }
            .addDisposableTo(disposeBag)
        
        
        RxStore.shared.deviceInfosObservable
            .map{ $0.count >= 5 }
            .bindTo(tableView.tableFooterView!.rx.isHidden)
            .addDisposableTo(disposeBag)

        tableView.rx.modelSelected(DeviceInfo.self).asObservable()
            .map{ $0.deviceId }
            .filterNil()
            .distinctUntilChanged()
            .bindTo(RxStore.shared.currentDeviceId)
            .addDisposableTo(disposeBag)
        
        tableView.rx.itemSelected.asDriver()
            .drive(onNext: { [weak self] _ in self?.showAccountKidsRulesuserController() })
            .addDisposableTo(disposeBag)
        
        viewModel.accountName.drive(accountNameOutlet.rx.text).addDisposableTo(disposeBag)
        viewModel.profile.drive(onNext: { [weak self] in self?.show(head: $0) }).addDisposableTo(disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enterSubject.onNext(true)
        
        propelToTargetController()
        self.navigationController?.navigationBar.isHidden = false
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sg = R.segue.accountAndChoseDeviceController.shwoMeSettings(segue: segue) {
            sg.destination.settingSaveBlock = { gender, height, heightUnit, weight, weightUnit, birthday, changedImage in
                
                var info = UserInfo.Profile()
                info.gender = gender
                info.weight = weight
                info.height = height
                info.birthday = birthday
                info.heightUnit = heightUnit
                info.weightUnit = weightUnit
                
                
                var result: Observable<ValidationResult>?
                if changedImage != nil {
                    result = FSManager.shared.uploadPngImage(with: changedImage!).map{$0.fid}.filterNil().takeLast(1).flatMap({fid ->Observable<ValidationResult> in
                        info.iconUrl = fid
                        return self.settingUserInfo(with: info)
                    })
                }else {
                    result = self.settingUserInfo(with: info)
                }
                
                result?.filter({$0.isValid == true}).subscribe(onNext: { _ in
                    UserInfo.shared.profile?.gender = info.gender
                    UserInfo.shared.profile?.height = info.height
                    UserInfo.shared.profile?.weight = info.weight
                    UserInfo.shared.profile?.birthday = info.birthday
                    UserInfo.shared.profile?.heightUnit = info.heightUnit
                    UserInfo.shared.profile?.weightUnit = info.weightUnit
                    if let img = changedImage {
                        UserInfo.shared.profile?.iconUrl = info.iconUrl
                        KingfisherManager.shared.cache.store(img, forKey: FSManager.imageUrl(with: info.iconUrl!))
                        self.show(head: UserInfo.shared.profile!)
                    }
                }).addDisposableTo(self.disposeBag)
            }
        }
    }
    
    func settingUserInfo(with info: UserInfo.Profile) -> Observable<ValidationResult>{
        return UserManager.shared.setUserInfo(userInfo: info).map{ flag -> ValidationResult in
            if flag {
                return ValidationResult.ok(message: "OK")
            }else{
                return ValidationResult.failed(message: "failed")
            }
        }
    }
    
}

extension AccountAndChoseDeviceController {
    
    func propelToTargetController() {
        if let target = Distribution.shared.target {
            switch target {
            case .kidInformation, .familyMember, .friendList,.updata :
                showAccountKidsRulesuserController()
            default: ()
            }
        }
    }
    
    fileprivate func showAccountKidsRulesuserController() {
        if let toVC = R.storyboard.account.accountKidsRulesuserController() {
            self.navigationController?.show(toVC, sender: nil)
        }
    }
    
    fileprivate func show(head profile: UserInfo.Profile) {
        let placeImg = CDFInitialsAvatar(
            rect: CGRect(x: 0, y: 0, width: headOutlet.frame.width, height: headOutlet.frame.height),
            fullName: profile.nickname ?? "")
            .imageRepresentation()!
        
        let imgUrl = URL(string: profile.iconUrl?.fsImageUrl ?? "")
        headOutlet.kf.setImage(with: imgUrl, placeholder: placeImg)
    }
}


extension DeviceType  {
    var image: UIImage {
        switch self {
        case .mb12:
            return R.image.device_ic_mb12()!
        case .familyWatch:
            return R.image.device_ic_kids()!
        case .other:
            return R.image.device_ic_mb22()!
        case .all:
            return R.image.device_ic_mb22()!
        }
    }
}


extension AccountAndChoseDeviceController: UITableViewDelegate {
    
    // to prevent swipe to delete behavior
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
}

fileprivate extension UIImageView {

    func image(gradientColors:[UIColor], locations: [Float] = []) {
        self.image = UIImage(gradientColors: gradientColors, size: self.frame.size, locations: locations)
    }
}
