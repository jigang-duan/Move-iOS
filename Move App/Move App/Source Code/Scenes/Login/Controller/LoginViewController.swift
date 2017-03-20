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
    var viewModel: LoginViewModel!

    @IBOutlet weak var accountValidationHCon: NSLayoutConstraint!
    @IBOutlet weak var passwordValidationHCon: NSLayoutConstraint!
    
    
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
    
    //Third-party login
    @IBOutlet weak var facebookLoginQulet: UIButton!
    @IBOutlet weak var twitterLoginQulet: UIButton!
    @IBOutlet weak var googleaddLoginQulet: UIButton!
    
     var state: String?
    //第三方做到无法获取返回值
//     Observable<OAuthSwift.ObservableElement>
    
     lazy var internalWebViewController: OAuthWebController = {
        let controller = OAuthWebController()
            controller.view = UIView(frame: UIScreen.main.bounds)
        controller.delegate = self
        controller.viewDidLoad()
        return controller
    }()
//    func facebookLoginaction() -> () {
//        //            UserManager.shared.tplogin(platform: "aa", openld: "bb", secret: "cc")
//        AuthService.shared.facebook(consumerKey: <#T##String#>, consumerSecret: <#T##String#>, state: <#T##String#>, authorizeURLHandler: <#T##OAuthSwiftURLHandlerType#>)
//    }
//    func googleaddLoginaction() -> () {
//        //            UserManager.shared.tplogin(platform: "aa", openld: "bb", secret: "cc")
//        AuthService.shared.googleDrive(consumerKey: <#T##String#>, consumerSecret: <#T##String#>, state: <#T##String#>, authorizeURLHandler: <#T##OAuthSwiftURLHandlerType#>)
//    }
//    func twitterLoginaction() -> () {
//        //            UserManager.shared.tplogin(platform: "aa", openld: "bb", secret: "cc")
//        AuthService.shared.twitter(consumerKey: <#T##String#>, consumerSecret: <#T##String#>, authorizeURLHandler: <#T##OAuthSwiftURLHandlerType#>)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        state = generateStateWithLength(len: 20) as String
        
        

        
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
            .drive(onNext: { [unowned self] valid in
                self.loginOutlet.isEnabled = valid
                self.loginOutlet.alpha = valid ? 1.0 : 0.5
            })
            .addDisposableTo(disposeBag)
        
        
        viewModel.logedIn
            .drive(onNext: { [unowned self] logedIn in
                self.emailOutlet.resignFirstResponder()
                self.passwordOutlet.resignFirstResponder()
                switch logedIn {
                case .failed(let message):
                    self.showAccountError(message)
                case .ok:
//                    self.dismiss(animated: true, completion: { 
//                        
//                    })
                    Distribution.shared.showMainScreen()
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

extension LoginViewController: OAuthWebViewControllerDelegate {
    #if os(iOS) || os(tvOS)
    
    func oauthWebViewControllerDidPresent() {
        
    }
    func oauthWebViewControllerDidDismiss() {
        
    }
    #endif
    
    func oauthWebViewControllerWillAppear() {
        
    }
    func oauthWebViewControllerDidAppear() {
        
    }
    func oauthWebViewControllerWillDisappear() {
        
    }
    func oauthWebViewControllerDidDisappear() {
        // Ensure all listeners are removed if presented web view close
//        oauthswift?.cancel()
    }
}



fileprivate func generateStateWithLength (len : Int) -> NSString {
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let randomString : NSMutableString = NSMutableString(capacity: len)
    for _ in 0..<len {
        let length = UInt32 (letters.length)
        let rand = arc4random_uniform(length)
        randomString.appendFormat("%C", letters.character(at: Int(rand)))
    }
    return randomString
}



