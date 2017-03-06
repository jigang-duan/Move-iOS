//
//  PhoneNumberController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/14.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PhoneNumberController: UIViewController {

    @IBOutlet weak var phoneTf: UITextField!
    @IBOutlet weak var nextBun: UIButton!
   
    var disposeBag = DisposeBag()
    var viewModel: PhoneNumberViewModel!
    
    var deviceAddInfo: DeviceFirstBindInfo?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.phoneInvalidte.drive(onNext: { result in
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
        phoneTf.resignFirstResponder()
    }
    
    func showValidateError(_ text: String) {
        
        //        emailValidation.isHidden = false
        //        emailValidation.alpha = 0.0
        //        emailValidation.text = text
        //        UIView.animate(withDuration: 0.6) { [weak self] in
        //            self?.emailValidation.textColor = ValidationColors.errorColor
        //            self?.emailValidation.alpha = 1.0
        //            self?.view.layoutIfNeeded()
        //        }
        phoneTf.placeholder = text
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
        
        phoneTf.placeholder = "please input phoneNumber"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        
        
        viewModel = PhoneNumberViewModel(
            input:(
                phone: phoneTf.rx.text.orEmpty.asDriver(),
                nextTaps: nextBun.rx.tap.asDriver()
            ),
            dependency: (
                userManager: UserManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        
        viewModel.nextEnabled
            .drive(onNext: { [weak self] valid in
                self?.nextBun.isEnabled = valid
                self?.nextBun.alpha = valid ? 1.0 : 0.5
            })
            .addDisposableTo(disposeBag)
        
        
        
        viewModel.nextResult
            .drive(onNext: { doneResult in
                switch doneResult {
                case .failed(let message):
                    self.showValidateError(message)
                case .ok(let message):
                    self.gotoRelationVC(message)
                default:
                    self.revertValidateError()
                }
            })
            .addDisposableTo(disposeBag)
        
    }
    
//    选择国家代号
    @IBAction func selectCountryCode(_ sender: UIButton) {
        let vc = CountryCodeViewController()
        self.navigationController?.show(vc, sender: nil)
    }
    
    func gotoRelationVC(_ msg: String){
        self.performSegue(withIdentifier: R.segue.phoneNumberController.showRelationship, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sg = R.segue.phoneNumberController.showRelationship(segue: segue) {
            self.deviceAddInfo?.phone = phoneTf.text
            sg.destination.deviceAddInfo = self.deviceAddInfo
        }
    }
    
   
    @IBAction func backAction(_ sender: AnyObject) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
