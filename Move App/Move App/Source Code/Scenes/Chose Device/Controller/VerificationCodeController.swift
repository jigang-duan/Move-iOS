//
//  VerificationCodeController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/14.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class VerificationCodeController: UIViewController {
    
    @IBOutlet weak var vcodeTf: UITextField!
    @IBOutlet weak var sendBun: UIButton!
    @IBOutlet weak var nextBun: UIButton!
    

    var disposeBag = DisposeBag()
    var viewModel: VerificationCodeViewModel!
    
    public var sid = ""
    
    func showValidateError(_ text: String) {
        
        //        emailValidation.isHidden = false
        //        emailValidation.alpha = 0.0
        //        emailValidation.text = text
        //        UIView.animate(withDuration: 0.6) { [weak self] in
        //            self?.emailValidation.textColor = ValidationColors.errorColor
        //            self?.emailValidation.alpha = 1.0
        //            self?.view.layoutIfNeeded()
        //        }
        vcodeTf.placeholder = text
    }
    
    func revertValidateError() {
        //        emailValidation.isHidden = true
        //        emailValidation.alpha = 1.0
        //        emailValidation.text = ""
        //        UIView.animate(withDuration: 0.6) { [weak self] in
        //            self?.emailValidation.textColor = ValidationColors.okColor
        //            self?.emailValidation.alpha = 0.0
        //            self?.view.layoutIfNeeded()
        //        }
        
        vcodeTf.placeholder = "please input vcode"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        
        
        viewModel = VerificationCodeViewModel(
            input:(
                vcode: vcodeTf.rx.text.orEmpty.asDriver(),
                sendTaps: sendBun.rx.tap.asDriver(),
                nextTaps: nextBun.rx.tap.asDriver()
            ),
            dependency: (
                userManager: UserManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        viewModel.sid = self.sid
        
        viewModel.sendEnabled
            .drive(onNext: { [weak self] valid in
                self?.sendBun.isEnabled = valid
                self?.sendBun.alpha = valid ? 1.0 : 0.5
            })
            .addDisposableTo(disposeBag)
        
        viewModel.nextEnabled
            .drive(onNext: { [weak self] valid in
                self?.nextBun.isEnabled = valid
                self?.nextBun.alpha = valid ? 1.0 : 0.5
            })
            .addDisposableTo(disposeBag)
        
        viewModel.sendResult?
            .drive(onNext: { doneResult in
                switch doneResult {
                case .failed(let message):
                    self.showValidateError(message)
                default:
                    self.revertValidateError()
                }
            })
            .addDisposableTo(disposeBag)
        
        viewModel.nextResult?
            .drive(onNext: { doneResult in
                switch doneResult {
                case .failed(let message):
                    self.showValidateError(message)
                    self.gotoPhoneNumberVC(message) //////for test
                case .ok(let message):
                    self.gotoPhoneNumberVC(message)
                default:
                    self.revertValidateError()
                }
            })
            .addDisposableTo(disposeBag)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.vcodeInvalidte.drive(onNext: { result in
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
        vcodeTf.resignFirstResponder()
    }
    
    @IBAction func backAction(_ sender: AnyObject) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func gotoPhoneNumberVC(_ msg: String){
        self.performSegue(withIdentifier: R.segue.verificationCodeController.showPhoneNumber, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = R.segue.verificationCodeController.showPhoneNumber(segue: segue) {
            
            ///
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}


