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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.phoneInvalidte
            .drive(onNext: { [weak self] result in
                switch result{
                case .failed(let message):
                    self?.showValidateError(message)
                default:
                    self?.revertValidateError()
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
        
        if let localModel = CountryCodeViewController.localCountryCode() {
            self.regionBun.setTitle(localModel.abbr, for: .normal)
            self.phonePrefix.text = localModel.code
        }
        
        
        viewModel = PhoneNumberViewModel(
            input:(
                phone: phoneTf.rx.text.orEmpty.asDriver(),
                nextTaps: nextBun.rx.tap.asDriver(),
                info: deviceAddInfo!
            ),
            dependency: (
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
        
        
        
        viewModel.nextResult?
            .drive(onNext: { [weak self] doneResult in
                switch doneResult {
                case .failed(let message):
                    self?.showValidateError(message)
                case .ok:
                    self?.performSegue(withIdentifier: R.segue.phoneNumberController.showRelationship, sender: nil)
                default:
                    self?.revertValidateError()
                }
            })
            .addDisposableTo(disposeBag)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        phoneTf.resignFirstResponder()
    }
    
    
//    选择国家代号
    @IBAction func selectCountryCode(_ sender: UIButton) {
        let vc = R.storyboard.kidInformation.countryCodeViewController()!
        vc.selectBlock = { [weak self] model in
            self?.regionBun.setTitle(model.abbr, for: .normal)
            self?.phonePrefix.text = model.code
        }
        self.navigationController?.show(vc, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sg = R.segue.phoneNumberController.showRelationship(segue: segue) {
            if let pre = phonePrefix.text, pre.characters.count > 0 {
                self.deviceAddInfo?.phone = "\(pre) \(phoneTf.text ?? "")"
            }else{
                self.deviceAddInfo?.phone = phoneTf.text
            }
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
