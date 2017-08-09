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
    
    @IBOutlet weak var validate: UILabel!

    
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var tipLab: UILabel!
    @IBOutlet weak var inputTip: UILabel!
    @IBOutlet weak var cantPairLab: UILabel!
    @IBOutlet weak var helpBun: UIButton!
    
    
    var disposeBag = DisposeBag()
    var viewModel: VerificationCodeViewModel!
    
    var imei: String?
    
    var timeCount = 0
    var timer: Timer?
    
    func showValidateError(_ text: String) {
        validate.isHidden = false
        validate.alpha = 0.0
        validate.text = text
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.validate.textColor = ValidationColors.errorColor
            self?.validate.alpha = 1.0
            self?.view.layoutIfNeeded()
        }
    }
    
    func revertValidateError() {
        validate.isHidden = true
        validate.alpha = 1.0
        validate.text = ""
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.validate.textColor = ValidationColors.okColor
            self?.validate.alpha = 0.0
            self?.view.layoutIfNeeded()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func initializeI18N() {
        titleLab.text = R.string.localizable.id_verification_code()
        
        tipLab.text = R.string.localizable.id_help_apn_code()
        inputTip.text = R.string.localizable.id_verification_code_prompt()
        vcodeTf.placeholder = R.string.localizable.id_verification_code()
        sendBun.setTitle(R.string.localizable.id_resend(), for: UIControlState.normal)
        nextBun.setTitle(R.string.localizable.id_confirm(), for: .normal)
        cantPairLab.text = R.string.localizable.id_verification_code_help()
        
        let help = NSMutableAttributedString(string: "q" + R.string.localizable.id_help())
        help.addAttributes([NSForegroundColorAttributeName: UIColor.clear], range: NSRange(location: 0, length: 1))
        help.addAttributes([NSForegroundColorAttributeName: UIColor.white], range: NSRange(location: 1, length: help.length - 1))
        help.addAttributes([NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue], range: NSRange.init(location: 0, length: help.length))
        
        helpBun.setAttributedTitle(help, for: .normal)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeI18N()
        
        tipLab.isHidden = true
        
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
        
        viewModel.vcodeInvalidte
            .drive(onNext: { [weak self] result in
                switch result{
                case .failed(let message):
                    self?.showValidateError(message)
                default:
                    self?.revertValidateError()
                }
            })
            .addDisposableTo(disposeBag)
        
        viewModel.sendEnabled?
            .drive(onNext: { [unowned self] valid in
                self.sendBun.isEnabled = valid
                self.sendBun.alpha = valid ? 1.0 : 0.5
                if valid {
                    self.sendBun.setTitle(R.string.localizable.id_resend(), for: UIControlState.normal)
                }else{
                    self.timeCount = 90
                    self.sendBun.setTitle(R.string.localizable.id_resend() + "(\(self.timeCount)s)", for: UIControlState.normal)
                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.setupSendBunTitle), userInfo: nil, repeats: true)
                }

            })
            .addDisposableTo(disposeBag)
        
        viewModel.nextEnabled.drive(nextBun.rx.enabled).addDisposableTo(disposeBag)
        
        
        viewModel.firstEnter?
            .drive(onNext: { [weak self] sendResult in
                switch sendResult {
                case .failed(let message):
                    self?.showValidateError(message)
                default:
                    self?.revertValidateError()
                }
            })
            .addDisposableTo(disposeBag)
        
        viewModel.sendResult?
            .drive(onNext: { [weak self] sendResult in
                switch sendResult {
                case .failed(let message):
                    self?.showValidateError(message)
                default:
                    self?.revertValidateError()
                }
            })
            .addDisposableTo(disposeBag)
        
        viewModel.nextResult?
            .drive(onNext: { [weak self] doneResult in
                switch doneResult {
                case .failed(let message):
                    self?.showValidateError(message)
                case .ok(let message):
                    self?.gotoPhoneNumberVC(message)
                default:
                    self?.revertValidateError()
                }
            })
            .addDisposableTo(disposeBag)
        
    }
    
    @objc func setupSendBunTitle() {
        timeCount -= 1
        if timeCount <= -1 {
            self.timer?.invalidate()
            self.sendBun.setTitle(R.string.localizable.id_resend(), for: UIControlState.normal)
            self.sendBun.isEnabled = true
            self.sendBun.alpha = 1
        }else{
            self.sendBun.setTitle(R.string.localizable.id_resend() + "(\(timeCount)s)", for: UIControlState.normal)
        }
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
        if let vc = R.segue.verificationCodeController.showPhoneNumber(segue: segue)?.destination {
            var addInfo = DeviceBindInfo()
            addInfo.deviceId = self.imei
            addInfo.sid = viewModel.sid
            addInfo.vcode = vcodeTf.text
            addInfo.isMaster = true
            vc.deviceAddInfo = addInfo
        }
        
        if let vc = R.segue.verificationCodeController.showHelp(segue: segue)?.destination {
            vc.imei = imei!
            vc.showTipBlock = { _ in
                self.tipLab.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: { 
                    self.tipLab.isHidden = true
                })
            }
        }
        
    }

}


