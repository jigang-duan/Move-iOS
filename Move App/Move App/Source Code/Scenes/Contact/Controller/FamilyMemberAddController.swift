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
    
    @IBOutlet weak var photoLab: UILabel!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var numberLab: UILabel!
    
    @IBOutlet weak var saveBun: UIBarButtonItem!
    
    @IBOutlet weak var photoImgV: UIImageView!
    @IBOutlet weak var identityLab: UILabel!
    @IBOutlet weak var numberTf: UITextField!

    @IBOutlet weak var validate: UILabel!
    
    @IBOutlet weak var countryCodeBun: UIButton!
    @IBOutlet weak var phonePreLab: UILabel!
    
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
    
    private func initializeI18N() {
        self.title = R.string.localizable.id_family_member()
        
        saveBun.title = R.string.localizable.id_save()
        photoLab.text = R.string.localizable.id_photo()
        titleLab.text = R.string.localizable.id_title()
        numberLab.text = R.string.localizable.id_number()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeI18N()
        
        validate.isHidden = true

        countryCodeBun.setTitle("-", for: .normal)
        phonePreLab.text = "-"
        
        
        numberTf.rx.text.orEmpty
            .bindNext({ [weak self] _ in
                self?.updateNumberVariable()
            })
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
    
    func updateNumberVariable() {
        if let number = numberTf.text, number.characters.count > 0 {
            if let pre = self.phonePreLab.text, pre != "-", pre.characters.count > 0 {
                self.numberVariable.value = "\(pre)@\(number)"
            }else{
                self.numberVariable.value = number
            }
        }else{
            self.numberVariable.value = ""
        }
    }
    
    
    @IBAction func selectPhoto(_ sender: UIButton) {
        photoPicker = ImageUtility()
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: R.string.localizable.id_take_a_photo(), style: .default) { _ in
            self.photoPicker?.selectPhoto(with: self, soureType: .camera, size: CGSize(width: 100, height: 100), callback: { [weak self] (image) in
                self?.photoImgV.image = image
                self?.photoVariable.value = image
            })
        }
        //缺Select from album
        let action2 = UIAlertAction(title: "Select from album", style: .default) { _ in
            self.photoPicker?.selectPhoto(with: self, soureType: .photoLibrary, size: CGSize(width: 100, height: 100), callback: { [weak self] (image) in
                self?.photoImgV.image = image
                self?.photoVariable.value = image
            })
        }
        let action3 = UIAlertAction(title: R.string.localizable.id_cancel(), style: .cancel)
        
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
    
    //    选择国家代号
    @IBAction func selectCountryCode(_ sender: UIButton) {
        let vc = R.storyboard.kidInformation.countryCodeViewController()!
        vc.selectBlock = { [weak self] model in
            self?.countryCodeBun.setTitle(model.abbr, for: .normal)
            self?.phonePreLab.text = model.code
            self?.updateNumberVariable()
        }
        self.navigationController?.show(vc, sender: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        numberTf.resignFirstResponder()
    }
    
    func showMessage(_ text: String) {
        self.validate.text = text
        self.validate.isHidden = false
    }
    
    
}
