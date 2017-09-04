//
//  MeSetPasswordVC.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MeSetPasswordViewController: UIViewController {
    
    
    @IBOutlet weak var saveBun: UIBarButtonItem!
    @IBOutlet weak var oldTf: UITextField!
    @IBOutlet weak var newTf: UITextField!
    
    @IBOutlet weak var oldValid: UILabel!
    @IBOutlet weak var newValid: UILabel!
    
    
    @IBOutlet weak var oldLab: UILabel!
    @IBOutlet weak var newLab: UILabel!
    
    var disposeBag = DisposeBag()
    var viewModel: MeSetPasswordViewModel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.validatedOld
            .drive(onNext: { [weak self] result in
                switch result{
                case .failed(let message):
                    self?.showOldError(message)
                default:
                    self?.revertOldError()
                }
            })
            .addDisposableTo(disposeBag)
        
        viewModel.validatedNew
            .drive(onNext: { [weak self] result in
                switch result{
                case .failed(let message):
                    self?.showNewError(message)
                default:
                    self?.revertNewError()
                }
            })
            .addDisposableTo(disposeBag)
    }

    
    func showOldError(_ text: String) {
        oldValid.text = text
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.oldValid.textColor = ValidationColors.errorColor
            self?.view.layoutIfNeeded()
        }
    }
    
    func revertOldError() {
        oldValid.text = " "
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.oldValid.textColor = ValidationColors.okColor
            self?.view.layoutIfNeeded()
        }
    }
    
    func showNewError(_ text: String) {
        newValid.text = text
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.newValid.textColor = ValidationColors.errorColor
            self?.view.layoutIfNeeded()
        }
    }
    
    func revertNewError() {
        newValid.text = " "
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.newValid.textColor = ValidationColors.okColor
            self?.view.layoutIfNeeded()
        }
    }
    
    private func initializeI18N() {
        self.title = R.string.localizable.id_change_password()
        oldLab.text = R.string.localizable.id_old_password()
        newLab.text = R.string.localizable.id_new_password()
        saveBun.title = R.string.localizable.id_save()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeI18N()
        oldValid.text = " "
        newValid.text = " "
        
        let oldText = oldTf.rx.observe(String.self, "text").filterNil()
        let oldDrier = oldTf.rx.text.orEmpty.asDriver()
        let combineOld = Driver.of(oldText.asDriver(onErrorJustReturn: ""), oldDrier).merge()
        
        combineOld.drive(onNext: {[weak self] passwd in
            if passwd.characters.count > 16 {
                self?.oldTf.text = passwd.substring(to: passwd.index(passwd.startIndex, offsetBy: 16))
            }
        }).addDisposableTo(disposeBag)
        
        let newText = newTf.rx.observe(String.self, "text").filterNil()
        let newDrier = newTf.rx.text.orEmpty.asDriver()
        let combineNew = Driver.of(newText.asDriver(onErrorJustReturn: ""), newDrier).merge()
        
        combineNew.drive(onNext: {[weak self] passwd in
            if passwd.characters.count > 16 {
                self?.newTf.text = passwd.substring(to: passwd.index(passwd.startIndex, offsetBy: 16))
            }
        }).addDisposableTo(disposeBag)
        
        viewModel = MeSetPasswordViewModel(
            input:(
                old: combineOld,
                new: combineNew,
                saveTaps: saveBun.rx.tap.asDriver()
            ),
            dependency: (
                userManager: UserManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
        ))
        
        viewModel.saveEnabled
            .drive(onNext: { [unowned self] valid in
                self.saveBun.isEnabled = valid
                self.saveBun.tintColor?.withAlphaComponent(valid ? 1.0 : 0.5)
            })
            .addDisposableTo(disposeBag)
        
        
        
        viewModel.saveResult
            .drive(onNext: { [unowned self] result in
                switch result {
                case .failed(let message):
                    self.showOldError(message)
                case .ok:
                    _ = self.navigationController?.popViewController(animated: true)
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    
    
    @IBAction func oldPasswordEyeClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        oldTf.isSecureTextEntry = !sender.isSelected
    }
    
    @IBAction func newPasswordEyeClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        newTf.isSecureTextEntry = !sender.isSelected
    }
    
    
    
}
