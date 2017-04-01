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

    @IBOutlet weak var accountValidationHCon: NSLayoutConstraint!
    @IBOutlet weak var passwordValidationHCon: NSLayoutConstraint!
    
    
    var thirdLogin = Variable(MoveApiUserWorker.LoginType.none)
    
    
    
    
    
    @IBAction func facebookLogin(_ sender: Any) {
        self.thirdLogin.value = .facebook
    }
    
    @IBAction func twitterLogin(_ sender: Any) {
        self.thirdLogin.value = .twitter
    }
    
    @IBAction func googleLogin(_ sender: Any) {
        self.thirdLogin.value = .google
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        accountValidationHCon.constant = 0
        emailValidationOutlet.isHidden = true
        passwordValidationHCon.constant = 0
        passwordValidationOutlet.isHidden = true
        
        let viewModel = LoginViewModel(
            input:(
                email: emailOutlet.rx.text.orEmpty.asDriver(),
                passwd: passwordOutlet.rx.text.orEmpty.asDriver(),
                loginTaps: loginOutlet.rx.tap.asDriver(),
                thirdLogin: thirdLogin.asDriver()
            ),
            dependency: (
                userManager: UserManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            ))
        
        viewModel.validatedEmail.drive(onNext: showAccountValidation).addDisposableTo(disposeBag)
        
        viewModel.validatedPassword.drive(onNext: showPasswordValidation).addDisposableTo(disposeBag)
        
        viewModel.loginEnabled.drive(loginOutlet.rx.enabled).addDisposableTo(disposeBag)
        
        viewModel.logedIn.drive(onNext: loginOnValidation).addDisposableTo(disposeBag)
        
        viewModel.logedIn.map { $0.isValid }.drive(MessageServer.share.subject).addDisposableTo(disposeBag)
        
        viewModel.thirdLoginResult.map { $0.isValid }.drive(MessageServer.share.subject).addDisposableTo(disposeBag)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        retractionKeyboard()
    }
    
}


// MARK: -- Show

extension LoginViewController {
    
    fileprivate func retractionKeyboard() {
        emailOutlet.resignFirstResponder()
        passwordOutlet.resignFirstResponder()
    }
    
    fileprivate func loginOnValidation(_ result: ValidationResult) {
        switch result {
        case .failed(let message):
            self.showAccountError(message)
        case .ok:
            retractionKeyboard()
            Distribution.shared.showMainScreen()
        default: ()
        }
    }
    
    fileprivate func showAccountValidation(_ result: ValidationResult) {
        switch result{
        case .failed(let message):
            self.showAccountError(message)
        default:
            self.revertAccountError()
        }
    }
    
    fileprivate func showPasswordValidation(_ result: ValidationResult) {
        switch result{
        case .failed(let message):
            self.showPasswordError(message)
        default:
            self.revertPasswordError()
        }
    }
    
    private func showAccountError(_ text: String) {
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
    
    private func revertAccountError() {
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
    
    private func showPasswordError(_ text: String) {
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
    
    private func revertPasswordError() {
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
    
}


