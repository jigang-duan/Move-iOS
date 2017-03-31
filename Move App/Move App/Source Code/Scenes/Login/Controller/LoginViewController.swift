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
import OAuthSwift

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
    
    //Third-party login
    @IBOutlet weak var facebookLoginQulet: UIButton!
    @IBOutlet weak var twitterLoginQulet: UIButton!
    @IBOutlet weak var googleaddLoginQulet: UIButton!
    
    var thirdLogin = Variable(MoveApiUserWorker.LoginType.none,"","")
    
    func facebookLogin() {
        ShareSDK.authorize(SSDKPlatformType.typeFacebook, settings: nil, onStateChanged: { (state : SSDKResponseState, user : SSDKUser?, error : Error?) -> Void in

            switch state{
            case SSDKResponseState.success:
                print("授权成功,用户信息为\(user)\n ----- 授权凭证为\(user?.credential)")
                self.thirdLogin.value = (.facebook,"344365305959182",user?.credential.token ?? "")
            case SSDKResponseState.fail:
                print("授权失败,错误描述:\(error)")
            case SSDKResponseState.cancel:
                print("操作取消")
            default:
                break
            }
        })
    }
    
    func twitterLogin() {
        ShareSDK.authorize(SSDKPlatformType.typeTwitter, settings: nil, onStateChanged: { (state : SSDKResponseState, user : SSDKUser?, error : Error?) -> Void in
            
            switch state{
            case SSDKResponseState.success:
                print("授权成功,用户信息为\(user)\n ----- 授权凭证为\(user?.credential)")
                self.thirdLogin.value = (.twitter,user?.credential.token ?? "",user?.credential.secret ?? "")
            case SSDKResponseState.fail:
                print("授权失败,错误描述:\(error)")
            case SSDKResponseState.cancel:
                print("操作取消")
            default:
                break
            }
        })
    }
    
    func googleaddLogin() {
        ShareSDK.authorize(SSDKPlatformType.typeGooglePlus, settings: nil, onStateChanged: { (state : SSDKResponseState, user : SSDKUser?, error : Error?) -> Void in
            
            switch state{
            case SSDKResponseState.success:
                print("授权成功,用户信息为\(user)\n ----- 授权凭证为\(user?.credential)")
                self.thirdLogin.value = (.google,user?.credential.token ?? "",(user?.credential.rawData["id_token"] as? String ?? "")!)
            case SSDKResponseState.fail:
                print("授权失败,错误描述:\(error)")
            case SSDKResponseState.cancel:
                print("操作取消")
            default:
                break
            }
        })
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        facebookLoginQulet.addTarget(self, action: #selector(self.facebookLogin), for: .touchUpInside)
        twitterLoginQulet.addTarget(self, action: #selector(self.twitterLogin), for: .touchUpInside)
        googleaddLoginQulet.addTarget(self, action: #selector(self.googleaddLogin), for: .touchUpInside)
        
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
        retractionKeyboard()
        switch result {
        case .failed(let message):
            self.showAccountError(message)
        case .ok:
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


