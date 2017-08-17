//
//  PwdRecoveryController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/11.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PwdRecoveryController: TranslucentNavBarController {

    @IBOutlet weak var helpLabel: UILabel!
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var emailValidation: UILabel!
    @IBOutlet weak var doneBun: UIButton!
    
    
    var viewModel: PwdRecoveryViewModel!
    var disposeBag = DisposeBag()


    func showValidateError(_ text: String) {
        emailValidation.isHidden = false
        emailValidation.alpha = 0.0
        emailValidation.text = text
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.emailValidation.textColor = ValidationColors.errorColor
            self?.emailValidation.alpha = 1.0
            self?.view.layoutIfNeeded()
        }
    }
    
    func revertValidateError() {
        emailValidation.isHidden = true
        emailValidation.alpha = 1.0
        emailValidation.text = ""
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.emailValidation.textColor = ValidationColors.okColor
            self?.emailValidation.alpha = 0.0
            self?.view.layoutIfNeeded()
        }
    }
    
    private func initializeI18N() {
        self.title = R.string.localizable.id_password_recovery()
        helpLabel.text = R.string.localizable.id_set_password_tint()
        emailTf.placeholder = R.string.localizable.id_email()
        doneBun.setTitle(R.string.localizable.id_done(), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeI18N()
        
        emailValidation.isHidden = true
        
        if let email = UserDefaults.standard.value(forKey: lastLoginAccount) as? String {
            emailTf.text = email
        }
        
        viewModel = PwdRecoveryViewModel(
            input:(
                email: emailTf.rx.text.orEmpty.asDriver(),
                doneTaps: doneBun.rx.tap.asDriver()
            ),
            dependency: (
                userManager: UserManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        
        viewModel.doneEnabled
            .drive(onNext: { [weak self] valid in
                self?.doneBun.isEnabled = valid
                self?.doneBun.alpha = valid ? 1.0 : 0.5
            })
            .addDisposableTo(disposeBag)
        
        
        
        viewModel.doneResult?
            .drive(onNext: { [weak self] doneResult in
                switch doneResult {
                case .failed(let message):
                    self?.showValidateError(message)
                case .ok:
                    self?.performSegue(withIdentifier: R.segue.pwdRecoveryController.showUpdatePassword, sender: nil)
                default:
                    self?.revertValidateError()
                }
            })
            .addDisposableTo(disposeBag)
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        emailTf.resignFirstResponder()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = R.segue.pwdRecoveryController.showUpdatePassword(segue: segue)?.destination {
            vc.sid = viewModel.sid
            vc.email = emailTf.text
        }
    }
    
}


