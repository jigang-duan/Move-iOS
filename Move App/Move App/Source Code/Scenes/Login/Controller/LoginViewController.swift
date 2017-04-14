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
    
    @IBOutlet weak var fecebookOutlet: UIButton!
    @IBOutlet weak var twitterOutlet: UIButton!
    @IBOutlet weak var googleOutlet: UIButton!
    
    var disposeBag = DisposeBag()

    @IBOutlet weak var accountValidationHCon: NSLayoutConstraint!
    @IBOutlet weak var passwordValidationHCon: NSLayoutConstraint!
    
    var thirdLogin = Variable(MoveApiUserWorker.LoginType.none)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        accountValidationHCon.constant = 0
        emailValidationOutlet.isHidden = true
        passwordValidationHCon.constant = 0
        passwordValidationOutlet.isHidden = true
        
        
        let passwdText = passwordOutlet.rx.observe(String.self, "text").filterNil()
        let passwdDrier = passwordOutlet.rx.text.orEmpty.asDriver()
        let combinePasswd = Driver.of(passwdText.asDriver(onErrorJustReturn: ""), passwdDrier).merge()
        
        combinePasswd.drive(onNext: {[weak self] passwd in
            if passwd.characters.count > 16 {
                self?.passwordOutlet.text = passwd.substring(to: passwd.index(passwd.startIndex, offsetBy: 16))
            }
        }).addDisposableTo(disposeBag)
        
        let viewModel = LoginViewModel(
            input:(
                email: emailOutlet.rx.text.orEmpty.asDriver(),
                passwd: combinePasswd,
                loginTaps: loginOutlet.rx.tap.asDriver(),
                thirdLogin: thirdLogin.asDriver()
            ),
            dependency: (
                userManager: UserManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            ))
        
        
        fecebookOutlet.rx.tap.asDriver()
            .map({ .facebook })
            .drive(thirdLogin)
            .addDisposableTo(disposeBag)
        
        twitterOutlet.rx.tap.asDriver()
            .map({ .twitter })
            .drive(thirdLogin)
            .addDisposableTo(disposeBag)
        
        googleOutlet.rx.tap.asDriver()
            .map({ .google })
            .drive(thirdLogin)
            .addDisposableTo(disposeBag)
        
        viewModel.validatedEmail
            .drive(onNext: { [weak self] in
                self?.showAccountValidation($0)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.validatedPassword
            .drive(onNext: { [weak self] in
                self?.showPasswordValidation($0)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.loginEnabled.drive(loginOutlet.rx.enabled).addDisposableTo(disposeBag)
        
        viewModel.logedIn
            .drive(onNext: { [weak self] in
                self?.loginOnValidation($0)
            })
            .addDisposableTo(disposeBag)
        
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


