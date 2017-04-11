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
    let enterSubject = BehaviorSubject<Bool>(value: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let startColor = UIColor(red: 19/255, green: 210/255, blue: 241/255, alpha: 1)
        let endColor = UIColor(red: 19/255, green: 130/255, blue: 237/255, alpha: 1)
        backImageView.image = UIImage(gradientColors: [startColor, endColor],size: CGSize(width: self.backImageView.frame.width, height: self.backImageView.frame.height),locations: [0.0,1.0])
        
        let selectedInext = tableView.rx.itemSelected.asDriver().map { $0.row }
        let viewModel = AccountAndChoseDeviceViewModel(
            input: (
                enter: enterSubject.asDriver(onErrorJustReturn: false),
                selectedInext: selectedInext
            ),
            dependency:(
                userManager: UserManager.shared,
                deviceManager: DeviceManager.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        tableView.rx
            .setDelegate(self)
            .addDisposableTo(disposeBag)
        
        viewModel.fetchDevices.drive(viewModel.devicesVariable).addDisposableTo(disposeBag)
        
        viewModel.devicesVariable.asDriver()
            .map(transfer)
            .drive(tableView.rx.items(cellIdentifier: R.reuseIdentifier.cellDevice.identifier, cellType: UITableViewCell.self)){ (row, element, cell) in
                cell.textLabel?.text = element.devType
                cell.detailTextLabel?.text = element.name
                cell.imageView?.image = UIImage(named: element.iconUrl!)
            }
            .addDisposableTo(disposeBag)
        
        viewModel.selected
            .drive(RxStore.shared.currentDeviceId)
            .addDisposableTo(disposeBag)
        
        viewModel.selected
            .drive(onNext: { [weak self] _ in
                self?.showAccountKidsRulesuserController()
            })
            .addDisposableTo(disposeBag)
        
        viewModel.head
            .drive(onNext: { [weak self] in
                self?.showHead(url: $0)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.accountName.drive(accountNameOutlet.rx.text).addDisposableTo(disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        enterSubject.onNext(true)
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
    
    fileprivate func showAccountKidsRulesuserController() {
        if let vc = R.storyboard.account.accountKidsRulesuserController() {
            self.navigationController?.show(vc, sender: nil)
        }
    }
    
    fileprivate func showHead(url: String) {
        let placeImg = CDFInitialsAvatar(
            rect: CGRect(x: 0, y: 0, width: headOutlet.frame.width, height: headOutlet.frame.height),
            fullName: UserInfo.shared.profile?.nickname ?? "")
            .imageRepresentation()!
        
        let imgUrl = URL(string: url.fsImageUrl)
        headOutlet.kf.setImage(with: imgUrl, placeholder: placeImg)
    }
}

fileprivate func transfer(deviceInfos: [DeviceInfo]) -> [DeviceCellData] {
    return deviceInfos.map {
        var deviceType = ""
        var icon = ""
        switch $0.pid ?? 0 {
        case 0x101:
            deviceType = "MB12"
            icon = "device_ic_mb12"
        case 0x201:
            deviceType = "Kids Watch 2"
            icon = "device_ic_kids"
        default:
            deviceType = "Other"
            icon = "device_ic_mb22"
        }
        return DeviceCellData(devType: deviceType, name: $0.user?.nickname, iconUrl: icon)
    }
}


extension AccountAndChoseDeviceController: UITableViewDelegate {
    
    // to prevent swipe to delete behavior
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
}
