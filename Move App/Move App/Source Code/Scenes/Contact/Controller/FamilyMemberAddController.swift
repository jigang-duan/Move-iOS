//
//  FamilyMemberAddController.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/7.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation
import AddressBookUI
import ContactsUI

class FamilyMemberAddController: UIViewController {
    
    
    @IBOutlet weak var saveBun: UIBarButtonItem!
    
    @IBOutlet weak var photoImgV: UIImageView!
    @IBOutlet weak var identityLab: UILabel!
    @IBOutlet weak var numberTf: UITextField!

    @IBOutlet weak var validate: UILabel!
    
    private var disposeBag = DisposeBag()

    private var photoPicker: ImageUtility?
    private let addressbookHelper = AddressbookUtility()
    
    private var photoVariable:Variable<UIImage?> = Variable(nil)
    private var identityVariable:Variable<Relation?> = Variable(nil)
    private var numberVariable:Variable<String?> = Variable(nil)
    
    
    private var contactInfo: ImContact?
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validate.isHidden = true

        
        numberTf.rx.text.orEmpty
            .bindTo(numberVariable)
            .addDisposableTo(disposeBag)
        
        let viewModel = FamilyMemberAddViewModel(
            input:(
                photo: photoVariable,
                identity: identityVariable,
                number: numberVariable,
                saveTaps: saveBun.rx.tap.asDriver()
            ),
            dependency: (
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        viewModel.saveEnabled
            .drive(onNext: { [weak self] valid in
                self?.saveBun.isEnabled = valid
                self?.saveBun.tintColor?.withAlphaComponent(valid ? 1.0 : 0.5)
            })
            .addDisposableTo(disposeBag)
        
        
        viewModel.saveResult?
            .drive(onNext: { [weak self] result in
                switch result {
                case .failed(let message):
                    self?.showMessage(message)
                case .ok:
                    _ = self?.navigationController?.popViewController(animated: true)
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)
        
    }
    
    
    @IBAction func selectPhoto(_ sender: UIButton) {
        photoPicker = ImageUtility()
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "Take a photo", style: .default) { _ in
            self.photoPicker?.selectPhoto(with: self, soureType: .camera, size: CGSize(width: 100, height: 100), callback: { [weak self] (image) in
                self?.photoImgV.image = image
                self?.photoVariable.value = image
            })
        }
        let action2 = UIAlertAction(title: "Select from album", style: .default) { _ in
            self.photoPicker?.selectPhoto(with: self, soureType: .photoLibrary, size: CGSize(width: 100, height: 100), callback: { [weak self] (image) in
                self?.photoImgV.image = image
                self?.photoVariable.value = image
            })
        }
        let action3 = UIAlertAction(title: "Cancel", style: .cancel)
        
        vc.addAction(action1)
        vc.addAction(action2)
        vc.addAction(action3)
        
        if let popover = vc.popoverPresentationController {
            popover.sourceView = sender.superview
            popover.sourceRect = sender.frame
        }
        
        self.present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func selectRelation(_ sender: Any) {
        let vc = R.storyboard.main.relationshipTableController()!
        vc.relationBlock = {[weak self] (relation) in
            self?.identityLab.text = relation.description
            self?.identityVariable.value = relation
        }
        self.navigationController?.show(vc, sender: nil)
    }
    
    
    @IBAction func selectPhone(_ sender: Any) {
        addressbookHelper.phoneCallback(with: self) {[unowned self] phones in
            if phones.count > 0 {
                let phone = phones[0]
                var str = ""
                for ch in phone.characters {
                    if "0123456789".characters.contains(ch){
                        str.append(ch)
                    }
                }
                self.numberTf.text = str
                self.numberVariable.value = str
            }
        }
    }
    
    
    func showMessage(_ text: String) {
        self.validate.text = text
        self.validate.isHidden = false
    }
    
    
}
