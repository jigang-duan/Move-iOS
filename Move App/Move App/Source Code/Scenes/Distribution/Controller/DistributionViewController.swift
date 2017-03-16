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
                meManager: MeManager.shared,
                userManager: UserManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        viewModel.enterLogin.debug()
            .drive(onNext: enterLoginScreen)
            .addDisposableTo(disposeBag)
        
        viewModel.enterChoose.debug()
            .drive(onNext: enterChoseDeviceScreen)
            .addDisposableTo(disposeBag)
        
        viewModel.enterMain.debug()
            .drive(onNext: enterMainScreen)
            .addDisposableTo(disposeBag)
        
        NotificationService.shared.rx.userInfo
            .bindNext({
                Logger.debug($0)
            })
            .addDisposableTo(disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    private var inlet = 0
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _segue = R.segue.distributionViewController.showMajor(segue: segue) {
            _segue.destination.inlet = inlet
        }
    }

    @IBAction func unwindSegueToDistribution(segue: UIStoryboardSegue) {
//        if let typeInfoChoseDevice = R.segue.accountAndChoseDeviceController.unwindChoseDevice(segue: segue) {
//            Logger.debug(typeInfoChoseDevice)
//        }
        
    }
    
    private func enterLoginScreen(enter: Bool) {
        if enter {
            self.performSegue(withIdentifier: R.segue.distributionViewController.showLogin, sender: nil)
        }
    }
    
    func enterChoseDeviceScreen(enter: Bool) {
        if enter {
            //self.performSegue(withIdentifier: R.segue.distributionViewController.showChoseDevice, sender: nil)
            inlet = 1
            self.performSegue(withIdentifier: R.segue.distributionViewController.showMajor, sender: nil)
        }
    }
    
    func enterMainScreen(enter: Bool) {
        if enter {
            self.performSegue(withIdentifier: R.segue.distributionViewController.showMajor, sender: nil)
        }
    }

}


