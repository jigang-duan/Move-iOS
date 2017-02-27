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

class UpdatePwdController: UIViewController {

    @IBOutlet weak var helpLabel: UILabel!
    @IBOutlet weak var vcodeTf: UITextField!
    @IBOutlet weak var vcodeValidation: UILabel!
    @IBOutlet weak var vcodeValidHConstrain: NSLayoutConstraint!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var passwordValidation: UILabel!
    @IBOutlet weak var passwdValidHConstrain: NSLayoutConstraint!
    @IBOutlet weak var rePasswordTf: UITextField!
    @IBOutlet weak var rePasswordValidation: UILabel!
    
    @IBOutlet weak var sendBun: UIButton!
    @IBOutlet weak var doneBun: UIButton!
    
    var sid = ""
    
    var viewModel: UpdatePswdViewModel!
    var disposeBag = DisposeBag()
    
    
    
    func showVcodeError(_ text: String) {
        vcodeValidHConstrain.constant = 16
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
        vcodeValidHConstrain.constant = 0
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
        vcodeValidHConstrain.constant = 0
        passwordValidation.isHidden = true
        passwdValidHConstrain.constant = 0
        rePasswordValidation.isHidden = true
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initUI()
        // Do any additional setup after loading the view.
        
        viewModel = UpdatePswdViewModel(
            input:(
                sid: self.sid,
                vcode: vcodeTf.rx.text.orEmpty.asDriver(),
                passwd: passwordTf.rx.text.orEmpty.asDriver(),
                rePasswd: rePasswordTf.rx.text.orEmpty.asDriver(),
                sendTaps: sendBun.rx.tap.asDriver(),
                doneTaps: doneBun.rx.tap.asDriver()
            ),
            dependency: (
                userManager: UserManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        viewModel.sendEnabled
            .drive(onNext: { [weak self] valid in
                self?.sendBun.isEnabled = valid
                self?.sendBun.alpha = valid ? 1.0 : 0.5
            })
            .addDisposableTo(disposeBag)
        
        viewModel.doneEnabled
            .drive(onNext: { [weak self] valid in
                self?.doneBun.isEnabled = valid
                self?.doneBun.alpha = valid ? 1.0 : 0.5
            })
            .addDisposableTo(disposeBag)
        
        viewModel.sendResult
            .drive(onNext: { signUped in
                switch signUped {
                case .failed(let message):
                    self.showVcodeError(message)
//                    self.gotoProtectVC()
//                case .ok:
//                    self.gotoProtectVC()
                default:
                    self.revertVcodeError()
                }
            })
            .addDisposableTo(disposeBag)
        
        viewModel.doneResult
            .drive(onNext: { signUped in
                switch signUped {
                case .failed(let message):
                    self.showVcodeError(message)
                    self.BackAction(self)
                case .ok:
                    self.BackAction(self)
                default:
                    self.revertVcodeError()
                }
            })
            .addDisposableTo(disposeBag)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.validatedVcode
            .drive(onNext: { result in
                switch result{
                case .failed(let message):
                    self.showVcodeError(message)
                default:
                    self.revertVcodeError()
                }
            })
            .addDisposableTo(disposeBag)
        
        viewModel.validatedPassword
            .drive(onNext: { result in
                switch result{
                case .failed(let message):
                    self.showPasswdError(message)
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
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        vcodeTf.resignFirstResponder()
        passwordTf.resignFirstResponder()
        rePasswordTf.resignFirstResponder()
    }
    
    
    @IBAction func BackAction(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }

   
}
extension UpdatePwdController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
}