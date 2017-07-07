//
//  SignUpViewController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SafariServices

class SignUpViewController: TranslucentNavBarController {

    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var emailValidation: UILabel!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var passwordValidation: UILabel!
    @IBOutlet weak var rePasswordTf: UITextField!
    @IBOutlet weak var rePasswordValidation: UILabel!
    
    @IBOutlet weak var signUpBtn: UIButton!
 
    @IBOutlet weak var terms_privacy: UITextView!
    var disposeBag = DisposeBag()
    
    fileprivate var emailSubject = PublishSubject<Void>()
    fileprivate var passwordSubject = PublishSubject<Void>()
    fileprivate var rePasswordSubject = PublishSubject<Void>()
    
    func showAccountError(_ text: String) {
        emailValidation.isHidden = false
        emailValidation.alpha = 0.0
        emailValidation.text = text
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.emailValidation.textColor = ValidationColors.errorColor
            self?.emailValidation.alpha = 1.0
            self?.view.layoutIfNeeded()
        }
    }
    
    func revertAccountError() {
        emailValidation.isHidden = true
        emailValidation.alpha = 1.0
        emailValidation.text = ""
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.emailValidation.textColor = ValidationColors.okColor
            self?.emailValidation.alpha = 0.0
            self?.view.layoutIfNeeded()
        }
    }
    
    func showPasswdError(_ text: String) {
        passwordValidation.isHidden = false
        passwordValidation.alpha = 0.0
        passwordValidation.text = text
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.passwordValidation.textColor = ValidationColors.errorColor
            self?.passwordValidation.alpha = 1.0
            self?.view.layoutIfNeeded()
        }
    }
    
    func revertPasswdError() {
        passwordValidation.isHidden = true
        passwordValidation.alpha = 1.0
        passwordValidation.text = ""
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.passwordValidation.textColor = ValidationColors.okColor
            self?.passwordValidation.alpha = 0.0
            self?.view.layoutIfNeeded()
        }
    }
    
    func showRePswdError(_ text: String) {
        rePasswordValidation.isHidden = false
        rePasswordValidation.alpha = 0.0
        rePasswordValidation.text = text
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.rePasswordValidation.textColor = ValidationColors.errorColor
            self?.rePasswordValidation.alpha = 1.0
            self?.view.layoutIfNeeded()
        }
    }
    
    func revertRePswdError() {
        rePasswordValidation.isHidden = true
        rePasswordValidation.alpha = 1.0
        rePasswordValidation.text = ""
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.rePasswordValidation.textColor = ValidationColors.okColor
            self?.rePasswordValidation.alpha = 0.0
            self?.view.layoutIfNeeded()
        }
    }
    
    func initUI() {
        emailValidation.text = nil
        passwordValidation.text = nil
        rePasswordValidation.text = nil
    }
    
    var viewModel: SignUpViewModel!
    
    
    
    private func initializeI18N() {
        self.title = R.string.localizable.id_sign_up()
        
        emailTf.placeholder = R.string.localizable.id_email()
        passwordTf.placeholder = R.string.localizable.id_password()
        rePasswordTf.placeholder = R.string.localizable.id_register_confirm_hint()
        signUpBtn.setTitle(R.string.localizable.id_sign_up(), for: .normal)
        
        
        
        let language = Bundle.main.preferredLocalizations[0].components(separatedBy: "-").first ?? "en"
        
        let termsUrl = URL(string: "http://www.tcl-move.com/help/#/mt30_terms_and_conditions/" + language)!
        let privacyUrl = URL(string: "http://www.tcl-move.com/help/#/mt30_privacy_policy/" + language)!
        
        let terms = NSAttributedString(string: R.string.localizable.id_terms_of_use_help(), attributes: [NSUnderlineStyleAttributeName: 1,NSLinkAttributeName: termsUrl,NSUnderlineColorAttributeName: UIColor.darkGray])
        let privacy = NSAttributedString(string: R.string.localizable.id_privacy_and_security(), attributes: [NSUnderlineStyleAttributeName: 1,NSLinkAttributeName: privacyUrl,NSUnderlineColorAttributeName: UIColor.darkGray])
        let link = NSMutableAttributedString(string: R.string.localizable.id_read_agree() + " ", attributes: [NSForegroundColorAttributeName: UIColor.darkGray])
        link.append(terms)
        link.append(NSAttributedString(string: " , "))
        link.append(privacy)
        terms_privacy.attributedText = link
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeI18N()
        
        self.initUI()
        // Do any additional setup after loading the view.
        
        
        let passwdText = passwordTf.rx.observe(String.self, "text").filterNil()
        let passwdDrier = passwordTf.rx.text.orEmpty.asDriver()
        let combinePasswd = Driver.of(passwdText.asDriver(onErrorJustReturn: ""), passwdDrier).merge()
        
        combinePasswd.drive(onNext: {[weak self] passwd in
            if passwd.characters.count > 16 {
                self?.passwordTf.text = passwd.substring(to: passwd.index(passwd.startIndex, offsetBy: 16))
            }
        }).addDisposableTo(disposeBag)
        
        let rePasswdText = rePasswordTf.rx.observe(String.self, "text").filterNil()
        let rePasswdDrier = rePasswordTf.rx.text.orEmpty.asDriver()
        let combineRePasswd = Driver.of(rePasswdText.asDriver(onErrorJustReturn: ""), rePasswdDrier).merge()
        
        combineRePasswd.drive(onNext: {[weak self] passwd in
            if passwd.characters.count > 16 {
                self?.rePasswordTf.text = passwd.substring(to: passwd.index(passwd.startIndex, offsetBy: 16))
            }
        }).addDisposableTo(disposeBag)
        
        viewModel = SignUpViewModel(
            input:(
                email: emailTf.rx.text.orEmpty.asDriver(),
                passwd: combinePasswd,
                rePasswd: combineRePasswd,
                signUpTaps: signUpBtn.rx.tap.asDriver()
            ),
            dependency: (
                userManager: UserManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        
        emailSubject.asDriver(onErrorJustReturn: ())
            .withLatestFrom(viewModel.validatedEmail)
            .drive(onNext: { [weak self] in
                self?.showEmailValidation($0)
            })
            .addDisposableTo(disposeBag)
        
        passwordSubject.asDriver(onErrorJustReturn: ())
            .withLatestFrom(viewModel.validatedPassword)
            .drive(onNext: { [weak self] in
                self?.showPasswordValidation($0)
            })
            .addDisposableTo(disposeBag)
        
        rePasswordSubject.asDriver(onErrorJustReturn: ())
            .withLatestFrom(viewModel.validatedRePassword)
            .drive(onNext: { [weak self] in
                self?.showRePasswordValidation($0)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.signUpEnabled
            .drive(onNext: { [weak self] valid in
                self?.signUpBtn.isEnabled = valid
                self?.signUpBtn.alpha = valid ? 1.0 : 0.5
            })
            .addDisposableTo(disposeBag)
        
        viewModel.signUped
            .drive(onNext: { [weak self] signUped in
                switch signUped {
                case .failed(let message):
                    self?.showAccountError(message)
                case .ok:
                    self?.gotoProtectVC()
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    
    func showEmailValidation(_ result: ValidationResult) {
        switch result{
        case .failed(let message):
            self.showAccountError(message)
        case .empty:
            self.showAccountError(R.string.localizable.id_password_please_fill_email())
        default:
            self.revertAccountError()
        }
    }
    
    func showPasswordValidation(_ result: ValidationResult) {
        switch result{
        case .failed(let message):
            self.showPasswdError(message)
        case .empty:
            self.showPasswdError(R.string.localizable.id_secure_your_account_email())
        default:
            self.revertPasswdError()
        }
    }

    func showRePasswordValidation(_ result: ValidationResult) {
        switch result{
        case .failed(let message):
            self.showRePswdError(message)
        case .empty:
            self.showRePswdError(R.string.localizable.id_password_please_fill_password())
        default:
            self.revertRePswdError()
        }
    }

    
    @IBAction func passwordEyeClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        passwordTf.isSecureTextEntry = !sender.isSelected
    }
    
    @IBAction func repasswordEyeClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        rePasswordTf.isSecureTextEntry = !sender.isSelected
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    
    func gotoProtectVC(){
        self.performSegue(withIdentifier: R.segue.signUpViewController.showProtectAccount, sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sg = R.segue.signUpViewController.showProtectAccount(segue: segue) {
            var info = MoveApi.RegisterInfo()
            info.email = emailTf.text
            info.password = passwordTf.text
            sg.destination.registerInfo = info
        }
    }
    
}


extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTf {
            emailSubject.onNext(())
        }
        if textField == passwordTf {
            passwordSubject.onNext(())
        }
        if textField == rePasswordTf {
            rePasswordSubject.onNext(())
        }
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTf {
            self.revertAccountError()
        }
        if textField == passwordTf {
            self.revertPasswdError()
        }
        if textField == rePasswordTf {
            self.revertRePswdError()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTf {
            passwordTf.becomeFirstResponder()
            return false
        }
        if textField == passwordTf {
            rePasswordTf.becomeFirstResponder()
            return false
        }
        return true
    }
    
}


