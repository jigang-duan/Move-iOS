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

    func cutString(_ text: String) -> String {
        var length = 0
        for char in text.characters {
            // 判断是否中文，是中文+2 ，不是+1
            length += "\(char)".lengthOfBytes(using: .utf8) >= 3 ? 2 : 1
        }
        
        if length > 11 {
            let str = text.characters.dropLast()
            return cutString(String(str))
        }
        
        return text
    }
    
    private func initializeI18N() {
        self.title = R.string.localizable.id_name()
        
        saveBun.title = R.string.localizable.id_save()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeI18N()
        
        nameValid.isHidden = true
        nameTf.text = UserInfo.shared.profile?.nickname
        
        let nameText = nameTf.rx.observe(String.self, "text").filterNil().asDriver(onErrorJustReturn: "")
        let nameDrier = nameTf.rx.text.orEmpty.asDriver()
        let combineName = Driver.of(nameText, nameDrier).merge()
        
        combineName.drive(onNext: {[weak self] name in
            if self?.nameTf.text != self?.cutString(name) {
                self?.nameTf.text = self?.cutString(name)
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

