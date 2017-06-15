//
//  InputImeiVC.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/14.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class InputImeiVC: UIViewController {

    @IBOutlet weak var IMEITextF: UITextField!
    @IBOutlet weak var confirmBun: UIButton!
    
    @IBOutlet weak var validate: UILabel!
    
    var disposeBag = DisposeBag()
    var viewModel: InputIMEIViewModel!
    
    
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
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validate.isHidden = true
        
        viewModel = InputIMEIViewModel(
            input:(
                imei: IMEITextF.rx.text.orEmpty.asDriver(),
                confirmTaps: confirmBun.rx.tap.asDriver()
            ),
            dependency: (
                deviceManager: DeviceManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        
        viewModel.confirmEnabled
            .drive(onNext: { [weak self] valid in
                self?.confirmBun.isEnabled = valid
                self?.confirmBun.alpha = valid ? 1.0 : 0.5
            })
            .addDisposableTo(disposeBag)
        
        
        
        viewModel.confirmResult?
            .drive(onNext: { [weak self] doneResult in
                switch doneResult {
                case .failed(let message):
                    self?.showValidateError(message)
                case .ok:
                    self?.performSegue(withIdentifier: R.segue.inputImeiVC.showVerification, sender: nil)
                default:
                    self?.revertValidateError()
                }
            })
            .addDisposableTo(disposeBag)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.imeiInvalidte
            .drive(onNext: { [weak self] result in
                switch result{
                case .failed(let message):
                    self?.showValidateError(message)
                case .empty:
                    self?.showValidateError("Please input IMEI")
                default:
                    self?.revertValidateError()
                }
            })
            .addDisposableTo(disposeBag)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IMEITextF.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sg = R.segue.inputImeiVC.showVerification(segue: segue) {
            sg.destination.imei = IMEITextF.text
        }
    }
    
    
}


