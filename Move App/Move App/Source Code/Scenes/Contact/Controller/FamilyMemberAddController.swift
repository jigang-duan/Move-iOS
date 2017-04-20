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
    
    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var numberTf: UITextField!

    @IBOutlet weak var validate: UILabel!
    
    var viewModel: FamilyMemberAddViewModel!
    var disposeBag = DisposeBag()

    var photoPicker: ImageUtility?
    
    let addressbookHelper = AddressbookUtility()
    
    var photoVariable:Variable<UIImage?> = Variable(nil)
    
    
    var contactInfo: ImContact?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.nameInvalidte.drive(onNext: { result in
            switch result{
            case .failed(_):
                self.nameTf.becomeFirstResponder()
            default:
                break
            }
        })
        .addDisposableTo(disposeBag)
        
        viewModel.phoneInvalidte.drive(onNext: { result in
            switch result{
            case .failed(let message):
                self.validate.text = message
                self.validate.isHidden = false
            default:
                self.validate.isHidden = true
            }
        })
        .addDisposableTo(disposeBag)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validate.isHidden = true
        
        let name = nameTf.rx.text.orEmpty.asDriver()
        let nameText = nameTf.rx.observe(String.self, "text").filterNil()
        let combineName = Driver.of(nameText.asDriver(onErrorJustReturn: ""), name).merge()
        
        let number = numberTf.rx.text.orEmpty.asDriver()
        let numberText = numberTf.rx.observe(String.self, "text").filterNil()
        let combineNumber = Driver.of(numberText.asDriver(onErrorJustReturn: ""), number).merge()
        
        viewModel = FamilyMemberAddViewModel(
            input:(
                name: combineName,
                number: combineNumber,
                saveTaps: saveBun.rx.tap.asDriver()
            ),
            dependency: (
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        viewModel.photo = photoVariable
        
        viewModel.saveEnabled
            .drive(onNext: { [weak self] valid in
                self?.saveBun.isEnabled = valid
                self?.saveBun.tintColor?.withAlphaComponent(valid ? 1.0 : 0.5)
            })
            .addDisposableTo(disposeBag)
        
        
        viewModel.saveResult?
            .drive(onNext: { result in
                switch result {
                case .failed(let message):
                    self.showMessage(message)
                case .ok:
                    self.fetchContactInfo()
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)
        
    }
    
    
    func fetchContactInfo() {
        DeviceManager.shared.getContacts(deviceId: RxStore.shared.currentDeviceId.value!)
            .subscribe(onNext: { cons in
                for con in cons {
                    if con.phone == self.numberTf.text {
                        self.contactInfo = con
                        let vc = R.storyboard.contact.familyMemberDetailController()!
                        vc.info = FamilyMemberDetailController.ContactDetailInfo(contactInfo: self.contactInfo, isNowMaster: true, isMe: false)
                        var vcs = self.navigationController?.viewControllers
                        _ = vcs?.popLast()
                        vcs?.append(vc)
                        self.navigationController?.setViewControllers(vcs!, animated: true)
                    }
                }
            }).addDisposableTo(disposeBag)
    }
    
    
    @IBAction func selectPhoto(_ sender: Any) {
        photoPicker = ImageUtility()
        photoPicker?.selectPhoto(with: self, soureType: .photoLibrary, size: CGSize(width: 100, height: 100), callback: { (image) in
            self.photoImgV.image = image
            self.photoVariable.value = image
        })
    }
    
    
    @IBAction func selectRelation(_ sender: Any) {
        let vc = R.storyboard.main.relationshipTableController()!
        vc.relationBlock = {[weak self] relation in
            if relation == 10 {
                self?.nameTf.text = "Other"
            }else{
                self?.nameTf.text = Relation(input: String(relation + 1))?.description
            }
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
            }
        }
    }
    
    
    func showMessage(_ text: String) {
        let vc = UIAlertController(title: "提示", message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        vc.addAction(action)
        self.present(vc, animated: true)
    }
    
    
}
