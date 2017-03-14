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
    
    var imei: String?
    
    var timeCount = 0
    var timer: Timer?
    
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
                imei: self.imei!,
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
        
        viewModel.sendEnabled?
            .drive(onNext: { [unowned self] valid in
                self.sendBun.isEnabled = valid
                self.sendBun.alpha = valid ? 1.0 : 0.5
                if valid {
                    self.sendBun.setTitle("Resend", for: UIControlState.normal)
                }else{
                    self.timeCount = 90
                    self.sendBun.setTitle("Resend(\(self.timeCount)s)", for: UIControlState.normal)
                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.setupSendBunTitle), userInfo: nil, repeats: true)
                }

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
                case .ok(let message):
                    self.gotoPhoneNumberVC(message)
                default:
                    self.revertValidateError()
                }
            })
            .addDisposableTo(disposeBag)
        
    }
    
    @objc func setupSendBunTitle() {
        timeCount -= 1
        if timeCount <= -1 {
            self.timer?.invalidate()
            self.sendBun.setTitle("Resend", for: UIControlState.normal)
            self.sendBun.isEnabled = true
            self.sendBun.alpha = 1
        }else{
            self.sendBun.setTitle("Resend(\(timeCount)s)", for: UIControlState.normal)
        }
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
        if let sg = R.segue.verificationCodeController.showPhoneNumber(segue: segue) {
            var addInfo = DeviceBindInfo()
            addInfo.deviceId = self.imei
            addInfo.sid = viewModel.sid
            addInfo.vcode = vcodeTf.text
            addInfo.isMaster = true
            sg.destination.deviceAddInfo = addInfo
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}


