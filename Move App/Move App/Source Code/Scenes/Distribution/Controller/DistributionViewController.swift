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
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var guideTitleLabel: UILabel!
    @IBOutlet weak var guideDescLabel: UILabel!
    
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        starButton.setTitle(R.string.localizable.id_start_to_use(), for: .normal)
        guideTitleLabel.text = R.string.localizable.id_layout_guide_foreground_title()
        guideDescLabel.text = R.string.localizable.id_layout_guide_foreground_text()
        
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        let noFirstKey = "no_first:tclmove:" + version
        let noFirst = UserDefaults.standard.bool(forKey: noFirstKey)
        showGuide(noFirst)
        
        let viewModel = DistributionViewModel(
            input: (
                starTap: starButton.rx.tap.asObservable(),
                noFirst: noFirst
            ),
            dependency: (
                deviceManager: DeviceManager.shared,
                userManager: UserManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        viewModel.enterLogin
            .drive(onNext: { [weak self] in
                UserDefaults.standard.set(true, forKey: noFirstKey)
                self?.showGuide(true)
                self?.enterLoginScreen(enter: $0)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.fetchDevices
            .drive(RxStore.shared.deviceInfosState)
            .addDisposableTo(disposeBag)
        
        viewModel.deviceId
            .drive(RxStore.shared.currentDeviceId)
            .addDisposableTo(disposeBag)
        
        RxStore.shared.cleanSubject.asObservable()
            .map{ [] }
            .bindTo(RxStore.shared.deviceInfosState)
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
    
    fileprivate func showGuide(_ noFirst: Bool) {
        #if Tag_ALCATEL
            backgroundImageView.image = noFirst ? R.image.defultAlcatel() : R.image.guide()
        #else
            backgroundImageView.image = noFirst ? R.image.defult() : R.image.guide()
        #endif
        starButton.isHidden = noFirst
        guideTitleLabel.isHidden = noFirst
        guideDescLabel.isHidden = noFirst
    }
    
    fileprivate func enterLoginScreen(enter: Bool) {
        let identifier = enter ? R.segue.distributionViewController.showLogin.identifier : R.segue.distributionViewController.showMajor.identifier
        self.performSegue(withIdentifier: identifier, sender: nil)
    }
}
