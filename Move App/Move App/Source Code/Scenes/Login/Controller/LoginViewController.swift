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
    
    @IBOutlet weak var errorTopConstraint: NSLayoutConstraint!
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func showAccountError(_ text: String) {
        errorTopConstraint.constant = 30
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
        errorTopConstraint.constant = 15
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let viewModel = LoginViewModel(
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
        
        viewModel.validatedEmail
            .drive(onNext: { [weak self] _ in
                self?.revertAccountError()
            })
            .addDisposableTo(disposeBag)
        
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
    
    
}
