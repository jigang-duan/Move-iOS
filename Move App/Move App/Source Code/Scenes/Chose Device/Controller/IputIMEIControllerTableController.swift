//
//  IputIMEIControllerTableController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/14.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class IputIMEIControllerTableController: UITableViewController {

    @IBOutlet weak var IMEITextF: UITextField!
    @IBOutlet weak var confirmBun: UIButton!
    
    
    var disposeBag = DisposeBag()
    var viewModel: InputIMEIViewModel!
    
    
    func showValidateError(_ text: String) {
        
//        emailValidation.isHidden = false
//        emailValidation.alpha = 0.0
//        emailValidation.text = text
//        UIView.animate(withDuration: 0.6) { [weak self] in
//            self?.emailValidation.textColor = ValidationColors.errorColor
//            self?.emailValidation.alpha = 1.0
//            self?.view.layoutIfNeeded()
//        }
        IMEITextF.placeholder = text
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
        
        IMEITextF.placeholder = "please input IMEI"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
      
        
        viewModel = InputIMEIViewModel(
            input:(
                imei: IMEITextF.rx.text.orEmpty.asDriver(),
                confirmTaps: confirmBun.rx.tap.asDriver()
            ),
            dependency: (
                userManager: UserManager.shared,
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
            .drive(onNext: { doneResult in
                switch doneResult {
                case .failed(let message):
                    self.showValidateError(message)
                case .ok(let message):
                    self.gotoVerifyVC(message)
                default:
                    self.revertValidateError()
                }
            })
            .addDisposableTo(disposeBag)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.imeiInvalidte.drive(onNext: { result in
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
        IMEITextF.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sg = R.segue.iputIMEIControllerTableController.showVerification(segue: segue) {
            sg.destination.sid = viewModel.sid
            sg.destination.imei = IMEITextF.text
        }
        
    }
    
    func gotoVerifyVC(_ sid: String){
        self.performSegue(withIdentifier: R.segue.iputIMEIControllerTableController.showVerification, sender: nil)
    }
    
    
}


