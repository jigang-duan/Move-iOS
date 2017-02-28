//
//  LoginViewController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailOutlet: UITextField!
    @IBOutlet weak var emailValidationOutlet: UILabel!
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidationOutlet: UILabel!
    @IBOutlet weak var loginOutlet: UIButton!
    @IBOutlet weak var emailLine: UIView!
    @IBOutlet weak var passwordLine: UIView!
    
    var disposeBag = DisposeBag()
    var viewModel: LoginViewModel!

    @IBOutlet weak var accountValidationHCon: NSLayoutConstraint!
    @IBOutlet weak var passwordValidationHCon: NSLayoutConstraint!
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func showAccountError(_ text: String) {
        accountValidationHCon.constant = 16
        emailValidationOutlet.isHidden = false
        emailValidationOutlet.alpha = 0.0
        emailValidationOutlet.text = text
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.emailValidationOutlet.textColor = ValidationColors.errorColor
            self?.emailLine.backgroundColor = ValidationColors.errorColor
            self?.emailValidationOutlet.alpha = 1.0
            self?.view.layoutIfNeeded()
        }
    }
    
    func revertAccountError() {
        accountValidationHCon.constant = 0
        emailValidationOutlet.isHidden = true
        emailValidationOutlet.alpha = 1.0
        emailValidationOutlet.text = ""
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.emailValidationOutlet.textColor = ValidationColors.okColor
            self?.emailLine.backgroundColor = ValidationColors.okColor
            self?.emailValidationOutlet.alpha = 0.0
            self?.view.layoutIfNeeded()
        }
    }
    
    func showPasswordError(_ text: String) {
        passwordValidationHCon.constant = 16
        passwordValidationOutlet.isHidden = false
        passwordValidationOutlet.alpha = 0.0
        passwordValidationOutlet.text = text
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.passwordValidationOutlet.textColor = ValidationColors.errorColor
            self?.passwordLine.backgroundColor = ValidationColors.errorColor
            self?.passwordValidationOutlet.alpha = 1.0
            self?.view.layoutIfNeeded()
        }
    }
    
    func revertPasswordError() {
        passwordValidationHCon.constant = 0
        passwordValidationOutlet.isHidden = true
        passwordValidationOutlet.alpha = 1.0
        passwordValidationOutlet.text = ""
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.passwordValidationOutlet.textColor = ValidationColors.okColor
            self?.passwordLine.backgroundColor = ValidationColors.okColor
            self?.passwordValidationOutlet.alpha = 0.0
            self?.view.layoutIfNeeded()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        accountValidationHCon.constant = 0
        emailValidationOutlet.isHidden = true
        passwordValidationHCon.constant = 0
        passwordValidationOutlet.isHidden = true
        
        
        viewModel = LoginViewModel(
            input:(
                email: emailOutlet.rx.text.orEmpty.asDriver(),
                passwd: passwordOutlet.rx.text.orEmpty.asDriver(),
                loginTaps: loginOutlet.rx.tap.asDriver()
            ),
            dependency: (
                userManager: UserManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            ))
        
        viewModel.loginEnabled
            .drive(onNext: { [weak self] valid in
                self?.loginOutlet.isEnabled = valid
                self?.loginOutlet.alpha = valid ? 1.0 : 0.5
            })
            .addDisposableTo(disposeBag)
        
//        viewModel.validatedEmail
//            .drive(emailValidationOutlet.rx.validationResult)
//            .addDisposableTo(disposeBag)
        
//        viewModel.validatedPassword
//            .drive(passwordValidationOutlet.rx.validationResult)
//            .addDisposableTo(disposeBag)
        
        viewModel.logedIn
            .drive(onNext: { logedIn in
                switch logedIn {
                case .failed(let message):
                    self.showAccountError(message)
                case .ok:
                    Distribution.shared.backToDistribution()
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.validatedEmail
            .drive(onNext: { result in
                    switch result{
                    case .failed(let message):
                        self.showAccountError(message)
                    default:
                        self.revertAccountError()
                    }
                })
            .addDisposableTo(disposeBag)
        
        viewModel.validatedPassword
            .drive(onNext: { result in
                switch result{
                case .failed(let message):
                    self.showPasswordError(message)
                default:
                    self.revertPasswordError()
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        emailOutlet.resignFirstResponder()
        passwordOutlet.resignFirstResponder()
    }
    
    
}
