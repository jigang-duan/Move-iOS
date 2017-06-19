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

let lastLoginAccount = "lastLoginAccount"

class LoginViewController: TranslucentNavBarController {
    
    @IBOutlet weak var emailOutlet: UITextField!
    @IBOutlet weak var emailValidationOutlet: UILabel!
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidationOutlet: UILabel!
    @IBOutlet weak var loginOutlet: UIButton!
    @IBOutlet weak var signUpBun: UIButton!
    @IBOutlet weak var forgotPswdBun: UIButton!
    @IBOutlet weak var emailLine: UIView!
    @IBOutlet weak var passwordLine: UIView!
    
    @IBOutlet weak var fecebookOutlet: UIButton!
    @IBOutlet weak var twitterOutlet: UIButton!
    @IBOutlet weak var googleOutlet: UIButton!
    
    var disposeBag = DisposeBag()

    @IBOutlet weak var accountValidationHCon: NSLayoutConstraint!
    @IBOutlet weak var passwordValidationHCon: NSLayoutConstraint!
    
    @IBOutlet weak var orLab: UILabel!
    var thirdLogin = Variable(MoveApiUserWorker.LoginType.none)
    
    fileprivate var emailSubject: PublishSubject<Void> = PublishSubject()
    fileprivate var passwordSubject: PublishSubject<Void> = PublishSubject()
    
    //for适配
    @IBOutlet weak var logoTopCons: NSLayoutConstraint!
    @IBOutlet weak var loginTopCons: NSLayoutConstraint!
    
    private func initializeI18N() {
        forgotPswdBun.setTitle(R.string.localizable.id_forget_password(), for: .normal)
        loginOutlet.setTitle(R.string.localizable.id_login_in(), for: .normal)
        signUpBun.setTitle(R.string.localizable.id_sign_up(), for: .normal)
        orLab.text = R.string.localizable.id_or()
        
        emailOutlet.placeholder = R.string.localizable.id_email()
        passwordOutlet.placeholder = R.string.localizable.id_password()
    }
    
    
    func setupUI() {
        let screenH = UIScreen.main.bounds.height
        if screenH < 500 {
            logoTopCons.constant = 20
            loginTopCons.constant = 10
        }else if screenH > 500 && screenH < 600 {
            logoTopCons.constant = 50
            loginTopCons.constant = 20
        }else{
            logoTopCons.constant = 75
            loginTopCons.constant = 50
        }
        
        accountValidationHCon.constant = 0
        emailValidationOutlet.isHidden = true
        passwordValidationHCon.constant = 0
        passwordValidationOutlet.isHidden = true
        
        if let email = UserDefaults.standard.value(forKey: lastLoginAccount) as? String {
            emailOutlet.text = email
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = R.color.appColor.primaryText()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: R.color.appColor.primaryText()]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeI18N()

        // Do any additional setup after loading the view.
        
        self.setupUI()
      
        
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
        
        emailSubject.asDriver(onErrorJustReturn: ())
            .withLatestFrom(viewModel.validatedEmail)
            .drive(onNext: { [weak self] in
                self?.showAccountValidation($0)
            })
            .addDisposableTo(disposeBag)
        
        passwordSubject.asDriver(onErrorJustReturn: ())
            .withLatestFrom(viewModel.validatedPassword)
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
        
        viewModel.thirdLoginResult
            .drive(onNext: { [weak self] in
                self?.loginOnValidation($0)
            })
            .addDisposableTo(disposeBag)
        
        
        
    }
    
    @IBAction func eyeButtonClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        passwordOutlet.isSecureTextEntry = !sender.isSelected
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        retractionKeyboard()
    }
    
}

extension LoginViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailOutlet {
            passwordOutlet.becomeFirstResponder()
            emailSubject.onNext(())
        }
        if textField == passwordOutlet {
            passwordSubject.onNext(())
        }
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailOutlet {
            self.revertAccountError()
        }
        if textField == passwordOutlet {
            self.revertPasswordError()
        }
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
            if message == R.string.localizable.id_password_not_same() {
                self.showPasswordError(message)
            }else{
                self.showAccountError(message)
            }
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
        case .empty:
            self.showAccountError("Please fill")
        default:
            self.revertAccountError()
        }
    }
    
    fileprivate func showPasswordValidation(_ result: ValidationResult) {
        switch result{
        case .failed(let message):
            self.showPasswordError(message)
        case .empty:
            self.showPasswordError("Please fill")
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
    
    fileprivate func revertAccountError() {
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
    
    fileprivate func revertPasswordError() {
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

