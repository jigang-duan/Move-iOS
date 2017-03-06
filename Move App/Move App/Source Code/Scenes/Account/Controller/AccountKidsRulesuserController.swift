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

class AccountKidsRulesuserController: UITableViewController {

    @IBOutlet weak var headQutlet: UIImageView!
    @IBOutlet weak var accountNameQutlet: UILabel!
    @IBOutlet weak var personalInformationQutlet: UIButton!
    let disposeBag = DisposeBag()
    let enterCount = Variable(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        personalInformationQutlet.rx.tap.bindNext { _ in
                Distribution.shared.showUserInformationScreen()
        }
        .addDisposableTo(disposeBag)
        
        let viewModel = AccountAndChoseDeviceViewModel(
            input: (enterCount.asObservable()),
            dependency:(
                userManager: UserManager.shared,
                deviceManager: DeviceManager.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        viewModel.head
            .drive(onNext: { [weak self] in
                self?.headQutlet.imageFromURL($0, placeholder: R.image.member_btn_contact_nor()!)
                })
            .addDisposableTo(disposeBag)
        
        viewModel.accountName
            .drive(accountNameQutlet.rx.text)
            .addDisposableTo(disposeBag)


    
}
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enterCount.value += 1
    }

    
}
