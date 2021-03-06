//
//  UpdataPwdController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/11.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UpdatePwdController: TranslucentNavBarController {

    @IBOutlet weak var helpLabel: UILabel!
    @IBOutlet weak var vcodeTf: UITextField!
    @IBOutlet weak var vcodeValidation: UILabel!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var passwordValidation: UILabel!
    @IBOutlet weak var rePasswordTf: UITextField!
    @IBOutlet weak var rePasswordValidation: UILabel!
    
    @IBOutlet weak var sendBun: UIButton!
    @IBOutlet weak var doneBun: UIButton!
    
    fileprivate var vcodeSubject = PublishSubject<Void>()
    fileprivate var passwordSubject = PublishSubject<Void>()
    fileprivate var rePasswordSubject = PublishSubject<Void>()
    
    var sid: String?
    var email: String?
    
    var viewModel: UpdatePswdViewModel!
    var disposeBag = DisposeBag()
    
    
    var timeCount = 0
    var timer: Timer?
    
    
    
    func showVcodeError(_ text: String) {
        vcodeValidation.isHidden = false
        vcodeValidation.alpha = 0.0
        vcodeValidation.text = text
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.vcodeValidation.textColor = ValidationColors.errorColor
            self?.vcodeValidation.alpha = 1.0
            self?.view.layoutIfNeeded()
        }
    }
    
    func revertVcodeError() {
        vcodeValidation.isHidden = true
        vcodeValidation.alpha = 1.0
        vcodeValidation.text = ""
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.vcodeValidation.textColor = ValidationColors.okColor
            self?.vcodeValidation.alpha = 0.0
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
        vcodeValidation.isHidden = true
        passwordValidation.isHidden = true
        rePasswordValidation.isHidden = true
    }
    
    private func initializeI18N() {
        self.title = R.string.localizable.id_password_recovery()
        
        helpLabel.text = R.string.localizable.id_sent_email_success_tint() + " " + self.email!
        vcodeTf.placeholder = R.string.localizable.id_verification_code()
        sendBun.setTitle(R.string.localizable.id_resend(), for: .normal)
        passwordTf.placeholder = R.string.localizable.id_new_password()
        rePasswordTf.placeholder = R.string.localizable.id_confirm_password()
        
        doneBun.setTitle(R.string.localizable.id_done(), for: .normal)
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
        
        viewModel = UpdatePswdViewModel(
            input:(
                vcode: vcodeTf.rx.text.orEmpty.asDriver(),
                passwd: combinePasswd,
                rePasswd: combineRePasswd,
                sendTaps: sendBun.rx.tap.asDriver(),
                doneTaps: doneBun.rx.tap.asDriver()
            ),
            dependency: (
                userManager: UserManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        vcodeSubject.asDriver(onErrorJustReturn: ())
            .withLatestFrom(viewModel.validatedVcode)
            .drive(onNext: { [weak self] in
                self?.showVcodeValidation($0)
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

        
        viewModel.sid = self.sid
        viewModel.email = self.email
        
        viewModel.sendEnabled?
            .drive(onNext: { [unowned self] valid in
                self.sendBun.isEnabled = valid
                self.sendBun.alpha = valid ? 1.0 : 0.5
                if valid {
                    self.sendBun.setTitle(R.string.localizable.id_resend(), for: .normal)
                }else{
                    self.timeCount = 90
                    self.sendBun.setTitle(R.string.localizable.id_resend() + "(\(self.timeCount)s)", for: UIControlState.normal)
                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.setupSendBunTitle), userInfo: nil, repeats: true)
                }
            })
            .addDisposableTo(disposeBag)
        
        viewModel.doneEnabled
            .drive(onNext: { [weak self] valid in
                self?.doneBun.isEnabled = valid
                self?.doneBun.alpha = valid ? 1.0 : 0.5
            })
            .addDisposableTo(disposeBag)
        
        viewModel.sendResult?
            .drive(onNext: { [weak self] signUped in
                switch signUped {
                case .failed(let message):
                    self?.showVcodeError(message)
                default:
                    self?.revertVcodeError()
                }
            })
            .addDisposableTo(disposeBag)
        
        viewModel.doneResult?
            .drive(onNext: { [weak self] signUped in
                switch signUped {
                case .failed(let message):
                    self?.showVcodeError(message)
                case .ok:
                    _ = self?.navigationController?.popToRootViewController(animated: true)
                default:
                    self?.revertVcodeError()
                }
            })
            .addDisposableTo(disposeBag)
        
    }
    
    @objc func setupSendBunTitle() {
        timeCount -= 1
        if timeCount <= -1 {
            self.timer?.invalidate()
            self.sendBun.setTitle(R.string.localizable.id_resend(), for: .normal)
            self.sendBun.isEnabled = true
            self.sendBun.alpha = 1
        }else{
            self.sendBun.setTitle(R.string.localizable.id_resend() + "(\(timeCount)s)", for: UIControlState.normal)
        }
    }
    
    
    func showVcodeValidation(_ result: ValidationResult) {
        switch result{
        case .failed(let message):
            self.showVcodeError(message)
        case .empty:
            self.showRePswdError(R.string.localizable.id_vcode_tint())
        default:
            self.revertVcodeError()
        }
    }
    
    func showPasswordValidation(_ result: ValidationResult) {
        switch result{
        case .failed(let message):
            self.showPasswdError(message)
        case .empty:
            self.showRePswdError(R.string.localizable.id_new_password())
        default:
            self.revertPasswdError()
        }
    }
    
    func showRePasswordValidation(_ result: ValidationResult) {
        switch result{
        case .failed(let message):
            self.showRePswdError(message)
        case .empty:
            self.showRePswdError(R.string.localizable.id_confirm_new_password())
        default:
            self.revertRePswdError()
        }
    }

   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        vcodeTf.resignFirstResponder()
        passwordTf.resignFirstResponder()
        rePasswordTf.resignFirstResponder()
    }
    
    @IBAction func passwordEyeClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        passwordTf.isSecureTextEntry = !sender.isSelected
    }
    
    @IBAction func repasswordEyeClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        rePasswordTf.isSecureTextEntry = !sender.isSelected
    }
    
   
}


extension UpdatePwdController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == vcodeTf {
            vcodeSubject.onNext(())
        }
        if textField == passwordTf {
            passwordSubject.onNext(())
        }
        if textField == rePasswordTf {
            rePasswordSubject.onNext(())
        }
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == vcodeTf {
            self.revertVcodeError()
        }
        if textField == passwordTf {
            self.revertPasswdError()
        }
        if textField == rePasswordTf {
            self.revertRePswdError()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == vcodeTf {
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


