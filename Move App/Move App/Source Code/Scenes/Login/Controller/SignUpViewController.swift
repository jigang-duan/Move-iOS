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

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var emailValidation: UILabel!
    @IBOutlet weak var emailValidHConstrain: NSLayoutConstraint!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var passwordValidation: UILabel!
    @IBOutlet weak var passwdValidHConstrain: NSLayoutConstraint!
    @IBOutlet weak var rePasswordTf: UITextField!
    @IBOutlet weak var rePasswordValidation: UILabel!
    @IBOutlet weak var rePasswdValidHConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var signUpBtn: UIButton!
 
    var disposeBag = DisposeBag()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    
    }
    
    func showAccountError(_ text: String) {
        emailValidHConstrain.constant = 16
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
        emailValidHConstrain.constant = 0
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
        passwdValidHConstrain.constant = 16
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
        passwdValidHConstrain.constant = 0
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
        rePasswdValidHConstrain.constant = 16
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
        rePasswdValidHConstrain.constant = 0
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
        emailValidation.isHidden = true
        emailValidHConstrain.constant = 0
        passwordValidation.isHidden = true
        passwdValidHConstrain.constant = 0
        rePasswordValidation.isHidden = true
        rePasswdValidHConstrain.constant = 0
    }
    
    var viewModel: SignUpViewModel!
    
    
    
    private func initializeI18N() {
        self.title = R.string.localizable.id_sign_up()
        
        emailTf.placeholder = R.string.localizable.id_email()
        passwordTf.placeholder = R.string.localizable.id_password()
        rePasswordTf.placeholder = R.string.localizable.id_re_enter_password()
        signUpBtn.setTitle(R.string.localizable.id_sign_up(), for: .normal)
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
        
        viewModel.signUpEnabled
            .drive(onNext: { [weak self] valid in
                self?.signUpBtn.isEnabled = valid
                self?.signUpBtn.alpha = valid ? 1.0 : 0.5
            })
            .addDisposableTo(disposeBag)
        
        viewModel.signUped
            .drive(onNext: { signUped in
                switch signUped {
                case .failed(let message):
                    self.showAccountError(message)
                case .ok:
                    self.gotoProtectVC()
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
                case .empty:
                    self.showAccountError("Please fill")
                default:
                    self.revertAccountError()
                }
            })
            .addDisposableTo(disposeBag)
        
        viewModel.validatedPassword
            .drive(onNext: { result in
                switch result{
                case .failed(let message):
                    self.showPasswdError(message)
                case .empty:
                    self.showPasswdError("Secure your account")
                default:
                    self.revertPasswdError()
                }
            })
            .addDisposableTo(disposeBag)
        
        viewModel.validatedRePassword
            .drive(onNext: { result in
                switch result{
                case .failed(let message):
                    self.showRePswdError(message)
                default:
                    self.revertRePswdError()
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    @IBAction func passwordEyeClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        passwordTf.isSecureTextEntry = !sender.isSelected
    }
    
    @IBAction func repasswordEyeClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        rePasswordTf.isSecureTextEntry = !sender.isSelected
    }

   
    
    //返回上一级页面
    @IBAction func BackAction(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    //使用条款
    @IBAction func UseTermsAction(_ sender: AnyObject) {
        let language = Locale.preferredLanguages.first?.components(separatedBy: "-").first ?? "en"
        
        let url = URL(string: "http://www.tcl-move.com/help/#/mt30_terms_and_conditions/" + language)!
        
        if #available(iOS 9.0, *) {
            let sVC = SFSafariViewController(url: url)
            self.present(sVC, animated: true, completion: nil)
        } else {
            let webVC = WebViewController()
            webVC.targetURL = url
            self.navigationController?.show(webVC, sender: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        emailTf.resignFirstResponder()
        passwordTf.resignFirstResponder()
        rePasswordTf.resignFirstResponder()
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
            passwordTf.becomeFirstResponder()
        }
        if textField == passwordTf {
            rePasswordTf.becomeFirstResponder()
        }
    }
    
}


extension SignUpViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
