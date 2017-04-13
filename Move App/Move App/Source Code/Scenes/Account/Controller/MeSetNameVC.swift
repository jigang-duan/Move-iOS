//
//  MeSetNameVC.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MeSetNameViewController: UIViewController {
    

    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var saveBun: UIBarButtonItem!
    @IBOutlet weak var nameValid: UILabel!
    
    var disposeBag = DisposeBag()
    var viewModel: MeSetNameViewModel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.validatedName
            .drive(onNext: { result in
                switch result{
                case .failed(let message):
                    self.showNameError(message)
                default:
                    self.revertNameError()
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        nameTf.resignFirstResponder()
    }
    
    
    func showNameError(_ text: String) {
        nameValid.isHidden = false
        nameValid.alpha = 0.0
        nameValid.text = text
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.nameValid.textColor = ValidationColors.errorColor
            self?.nameValid.alpha = 1.0
            self?.view.layoutIfNeeded()
        }
    }
    
    func revertNameError() {
        nameValid.isHidden = true
        nameValid.alpha = 1.0
        nameValid.text = ""
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.nameValid.textColor = ValidationColors.okColor
            self?.nameValid.alpha = 0.0
            self?.view.layoutIfNeeded()
        }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        nameValid.isHidden = true
        
        let nameText = nameTf.rx.observe(String.self, "text").filterNil()
        let nameDrier = nameTf.rx.text.orEmpty.asDriver()
        let combineName = Driver.of(nameText.asDriver(onErrorJustReturn: ""), nameDrier).merge()
        
        combineName.drive(onNext: {[weak self] name in
            if name.characters.count > 14 {
                self?.nameTf.text = name.substring(to: name.index(name.startIndex, offsetBy: 14))
            }
        }).addDisposableTo(disposeBag)
        
        viewModel = MeSetNameViewModel(
            input:(
                name: combineName,
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
                self.nameTf.resignFirstResponder()
                switch result {
                case .failed(let message):
                    self.showNameError(message)
                case .ok:
                    _ = self.navigationController?.popViewController(animated: true)
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    
    
    
    
}

