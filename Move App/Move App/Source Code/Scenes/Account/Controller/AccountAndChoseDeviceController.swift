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


class AccountAndChoseDeviceController: UIViewController {

    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var headOutlet: UIImageView!
    @IBOutlet weak var accountNameOutlet: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    let enterSubject = PublishSubject<Bool>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backImageView.image(gradientColors: [R.color.appColor.darkPrimary()], locations: [0.0,1.0])
        
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
        self.navigationController?.navigationBar.isHidden = true
        enterSubject.onNext(true)
        
        propelToTargetController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension AccountAndChoseDeviceController {
    
    func propelToTargetController() {
        if let target = Distribution.shared.target {
            switch target {
            case .kidInformation, .familyMember, .friendList :
                showAccountKidsRulesuserController()
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
