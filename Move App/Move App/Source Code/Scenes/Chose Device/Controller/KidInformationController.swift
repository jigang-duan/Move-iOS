//
//  KidInformationController.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/3.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class KidInformationController: UIViewController {
    
    @IBOutlet weak var nextBun: UIButton!
    
    var deviceAddInfo: DeviceBindInfo?
    
    var viewModel: KidInformationViewModel!
    var disposeBag = DisposeBag()
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if deviceAddInfo?.nickName == nil {
            deviceAddInfo?.nickName = "baby"
        }
        if deviceAddInfo?.number == nil {
            deviceAddInfo?.number = "18665313976"
        }
        if deviceAddInfo?.gender == nil {
            deviceAddInfo?.gender = "female"
        }
//        if deviceAddInfo?.profile == nil {
//            deviceAddInfo?.profile = ""
//        }
        
        
        
        viewModel = KidInformationViewModel(
            input:(
                nextTaps: nextBun.rx.tap.asDriver()
            ),
            dependency: (
                deviceManager: DeviceManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        viewModel.addInfo = self.deviceAddInfo
        
        viewModel.nextEnabled
            .drive(onNext: { [weak self] valid in
                self?.nextBun.isEnabled = valid
                self?.nextBun.alpha = valid ? 1.0 : 0.5
            })
            .addDisposableTo(disposeBag)
        
        
        viewModel.nextResult?
            .drive(onNext: { doneResult in
                switch doneResult {
                case .failed(let message):
                    self.showMessage(message)
                case .ok(let message):
                    self.showMessage(message)
                    let vcs = self.navigationController?.viewControllers
                    for vc in vcs! {
                        if vc is ChoseDeviceController {
                            _ = self.navigationController?.popToViewController(vc, animated: true)
                            break
                        }
                    }
                    _ = self.navigationController?.popViewController(animated: true)
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)
    }
    

    func showMessage(_ text: String) {
        let vc = UIAlertController.init(title: "提示", message: text, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        vc.addAction(action)
        self.present(vc, animated: true) {
            
        }
    }
    
    
    @IBAction func genderAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: R.segue.kidInformationController.setGenderVC, sender: nil)
    }
    
    @IBAction func birthdayAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: R.segue.kidInformationController.setBirthdayVC, sender: nil)
    }
    
    @IBAction func weightAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: R.segue.kidInformationController.setWeightVC, sender: nil)
    }
    
    @IBAction func heightAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: R.segue.kidInformationController.setHeightVC, sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sg = R.segue.kidInformationController.setGenderVC(segue: segue) {
            sg.destination.genderBlock = { (gender) in
                self.deviceAddInfo?.gender = gender
                self.viewModel.addInfo = self.deviceAddInfo
            }
        }
        if let sg = R.segue.kidInformationController.setBirthdayVC(segue: segue) {
            sg.destination.birthdayBlock = { (birthday) in
                self.deviceAddInfo?.birthday = birthday
                self.viewModel.addInfo = self.deviceAddInfo
            }
        }
        if let sg = R.segue.kidInformationController.setWeightVC(segue: segue) {
            sg.destination.weightBlock = { (weight) in
                self.deviceAddInfo?.weight = weight
                self.viewModel.addInfo = self.deviceAddInfo
            }
        }
        if let sg = R.segue.kidInformationController.setHeightVC(segue: segue) {
            sg.destination.heightBlock = { (height) in
                self.deviceAddInfo?.height = height
                self.viewModel.addInfo = self.deviceAddInfo
            }
        }
    }
    
}











