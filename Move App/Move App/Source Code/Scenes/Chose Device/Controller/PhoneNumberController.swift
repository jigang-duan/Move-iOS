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

    @IBOutlet weak var regionBun: UIButton!
    
    @IBOutlet weak var phoneTf: UITextField!
    @IBOutlet weak var nextBun: UIButton!
   
    @IBOutlet weak var phonePrefix: UILabel!
    @IBOutlet weak var validate: UILabel!
    
    
    var disposeBag = DisposeBag()
    var viewModel: PhoneNumberViewModel!
    
    var deviceAddInfo: DeviceBindInfo?
    
    var isForCheckNumber = false
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isForCheckNumber {
            return
        }
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validate.isHidden = true
        
        if isForCheckNumber {
            var phone = (deviceAddInfo?.phone)!
            phone = phone.substring(to: phone.index(phone.endIndex, offsetBy: -4))
            phonePrefix.text = phone
            
            phoneTf.placeholder = "****"
            
            self.showValidateError("Please input the last 4 number to verify")
        }else{
            phonePrefix.text = "+\(Locale.current.regionCode)"
            regionBun.setTitle(Locale.current.regionCode, for: .normal)
        }
        
        
        viewModel = PhoneNumberViewModel(
            input:(
                forCheckNumber: isForCheckNumber,
                phone: phoneTf.rx.text.orEmpty.asDriver(),
                nextTaps: nextBun.rx.tap.asDriver()
            ),
            dependency: (
                deviceManager: DeviceManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        viewModel.info = deviceAddInfo
        
        
        viewModel.nextEnabled
            .drive(onNext: { [weak self] valid in
                self?.nextBun.isEnabled = valid
                self?.nextBun.alpha = valid ? 1.0 : 0.5
            })
            .addDisposableTo(disposeBag)
        
        
        
        viewModel.nextResult?
            .drive(onNext: { doneResult in
                switch doneResult {
                case .failed(let message):
                    self.showValidateError(message)
                case .ok(let message):
                    if self.isForCheckNumber {
                        _ = self.navigationController?.popToRootViewController(animated: true)
                    }else{
                        self.gotoRelationVC(message)
                    }
                default:
                    self.revertValidateError()
                }
            })
            .addDisposableTo(disposeBag)
        
    }
    
//    选择国家代号
    @IBAction func selectCountryCode(_ sender: UIButton) {
        let vc = R.storyboard.kidInformation.countryCodeViewController()!
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
