//
//  DistributionViewController.swift
//  Move App
//
//  Created by Jiang Duan on 17/1/19.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class DistributionViewController: UIViewController {
    
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let viewModel = DistributionViewModel(
            dependency: (
                deviceManager: DeviceManager.shared,
                userManager: UserManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        viewModel.enterLogin
            .drive(onNext: { [weak self] in
                self?.enterLoginScreen(enter: $0)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.fetchDevices
            .drive(RxStore.shared.deviceInfosState)
            .addDisposableTo(disposeBag)
        
        viewModel.deviceId
            .drive(RxStore.shared.currentDeviceId)
            .addDisposableTo(disposeBag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

    @IBAction func unwindSegueToDistribution(segue: UIStoryboardSegue) {
    }
}


extension DistributionViewController {
    
    fileprivate func enterLoginScreen(enter: Bool) {
        if enter {
            self.performSegue(withIdentifier: R.segue.distributionViewController.showLogin, sender: nil)
        } else {
            self.performSegue(withIdentifier: R.segue.distributionViewController.showMajor, sender: nil)
        }
    }
}
