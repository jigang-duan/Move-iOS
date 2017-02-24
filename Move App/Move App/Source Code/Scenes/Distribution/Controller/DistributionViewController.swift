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
        
        viewModel.enterLogin
            .drive(onNext: { [weak self] enter in
                if enter {
                    self?.enterLoginScreen()
                }
            })
            .addDisposableTo(disposeBag)
        
        viewModel.enterChoose
            .drive(onNext: { [weak self] enter in
                if enter {
                    self?.enterChoseDeviceScreen()
                }
            })
            .addDisposableTo(disposeBag)
        
        viewModel.enterMain
            .drive(onNext: { [weak self] enter in
                if enter {
                    self?.enterMainScreen()
                }
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

    @IBAction func unwindSegueToDistribution(segue: UIStoryboardSegue) {
        if let typeInfoChoseDevice = R.segue.choseDeviceController.unwindChoseDevice(segue: segue) {
            Logger.debug(typeInfoChoseDevice)
        }
        
    }
    
    func enterLoginScreen() {
        self.performSegue(withIdentifier: R.segue.distributionViewController.showLogin.identifier, sender: nil)
    }
    
    func enterChoseDeviceScreen() {
        self.performSegue(withIdentifier: R.segue.distributionViewController.showChoseDevice.identifier, sender: nil)
    }
    
    func enterMainScreen() {
        fatalError("enterMainScreen(:) has not been implemented")
    }

}


