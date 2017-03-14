//
//  PwdRecoveryController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/11.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PwdRecoveryController: UIViewController {

    @IBOutlet weak var helpLabel: UILabel!
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var emailValidation: UILabel!
    @IBOutlet weak var doneBun: UIButton!
    
    
    var viewModel: PwdRecoveryViewModel!
    var disposeBag = DisposeBag()

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    

    func showValidateError(_ text: String) {
        emailValidation.isHidden = false
        emailValidation.alpha = 0.0
        emailValidation.text = text
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.emailValidation.textColor = ValidationColors.errorColor
            self?.emailValidation.alpha = 1.0
            self?.view.layoutIfNeeded()
        }
    }
    
    func revertValidateError() {
        emailValidation.isHidden = true
        emailValidation.alpha = 1.0
        emailValidation.text = ""
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.emailValidation.textColor = ValidationColors.okColor
            self?.emailValidation.alpha = 0.0
            self?.view.layoutIfNeeded()
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        emailValidation.isHidden = true
        
        viewModel = PwdRecoveryViewModel(
            input:(
                email: emailTf.rx.text.orEmpty.asDriver(),
                doneTaps: doneBun.rx.tap.asDriver()
            ),
            dependency: (
                userManager: UserManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        
        viewModel.doneEnabled
            .drive(onNext: { [weak self] valid in
                self?.doneBun.isEnabled = valid
                self?.doneBun.alpha = valid ? 1.0 : 0.5
            })
            .addDisposableTo(disposeBag)
        
        
        
        viewModel.doneResult?
            .drive(onNext: { doneResult in 
                switch doneResult {
                case .failed(let message):
                    self.showValidateError(message)
                case .ok(let message):
                    self.gotoUpdatePswdVC(message)
                default:
                    self.revertValidateError()
                }
            })
            .addDisposableTo(disposeBag)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.emailInvalidte.drive(onNext: { result in
            switch result{
            case .failed(let message):
                self.showValidateError(message)
            default:
                self.revertValidateError()
            }
        })
            .addDisposableTo(disposeBag)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        emailTf.resignFirstResponder()
    }
    
    
    @IBAction func backAction(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    

    func gotoUpdatePswdVC(_ sid: String){
        self.performSegue(withIdentifier: R.segue.pwdRecoveryController.showUpdatePassword, sender: nil)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sg = R.segue.pwdRecoveryController.showUpdatePassword(segue: segue) {
            sg.destination.sid = viewModel.sid
            sg.destination.email = emailTf.text
        }
    }
    
}
extension PwdRecoveryController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

