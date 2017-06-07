//
//  EmergencyNumberVC.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/23.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa



class EmergencyNumberVC: UIViewController {
    
    
    
    @IBOutlet weak var saveBun: UIBarButtonItem!
    @IBOutlet weak var numberTf: UITextField!
    @IBOutlet weak var validate: UILabel!

    
    
    var viewModel: EmergencyNumberViewModel!
    
    var disposeBag = DisposeBag()
    
    var numbers = ""
    
    
    
    func showValidateError(_ text: String) {
        validate.isHidden = false
        validate.alpha = 0.0
        validate.text = text
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.validate.textColor = ValidationColors.errorColor
            self?.validate.alpha = 1.0
            self?.view.layoutIfNeeded()
        }
    }
    
    func revertValidateError() {
        validate.isHidden = true
        validate.alpha = 1.0
        validate.text = ""
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.validate.textColor = ValidationColors.okColor
            self?.validate.alpha = 0.0
            self?.view.layoutIfNeeded()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validate.isHidden = true
        
        numberTf.text = numbers
        
        viewModel = EmergencyNumberViewModel(
            input: (
                phone: numberTf.rx.text.orEmpty.asDriver(),
                saveTaps: saveBun.rx.tap.asDriver()
            ),
            dependency: (
                watchManager: WatchSettingsManager.share,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        viewModel.saveEnable?
            .drive(onNext: { [weak self] valid in
                self?.saveBun.isEnabled = valid
                self?.saveBun.tintColor?.withAlphaComponent(valid ? 1.0 : 0.5)
            })
            .addDisposableTo(disposeBag)
        
        
        viewModel.saveResult?.drive(onNext: { [weak self] res in
            switch res {
            case .ok(_):
                _ = self?.navigationController?.popViewController(animated: true)
            case .failed(let message):
                print(message)
            default:
                break
            }
        }).addDisposableTo(disposeBag)
        
        
        
        viewModel.phoneInvalidte.drive(onNext: { [weak self] res in
            switch res {
            case .ok(_):
                self?.revertValidateError()
            case .failed(let message):
                self?.showValidateError(message)
            default:
                break
            }
        }).addDisposableTo(disposeBag)
        
        
    }
    
    
    
    
    
    
    
}





