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
    
    @IBOutlet weak var photoLab: UILabel!
    @IBOutlet weak var numberLab: UILabel!
    
    @IBOutlet weak var saveBun: UIBarButtonItem!
    @IBOutlet weak var numberTf: UITextField!
    @IBOutlet weak var validate: UILabel!

    
    
    var viewModel: EmergencyNumberViewModel!
    
    var disposeBag = DisposeBag()
    
    var numbers = ""
    
    private func initializeI18N() {
        self.title = R.string.localizable.id_family_emergency_number()
        
        saveBun.title = R.string.localizable.id_save()
        photoLab.text = R.string.localizable.id_photo()
        numberLab.text = R.string.localizable.id_number()
        numberTf.placeholder = R.string.localizable.id_emergency_number_tips()
    }
    
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
        
        self.initializeI18N()
        
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
                self?.showValidateError(message)
            default:
                break
            }
        }).addDisposableTo(disposeBag)
        
        
        
    }
    
    
    
    
    
    
    
}





