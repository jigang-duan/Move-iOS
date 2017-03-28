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
    
    @IBOutlet weak var doneBun: UIButton!

    
    var viewModel: FamilyMemberAddViewModel!
    var disposeBag = DisposeBag()

    var photoPicker: ImageUtility?
    
    let addressbookHelper = AddressbookUtility()
    
    var photoVariable:Variable<UIImage?> = Variable(nil)
    
    
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
            case .failed(_):
                self.numberTf.becomeFirstResponder()
            default:
                break
            }
        })
            .addDisposableTo(disposeBag)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        nameTf.resignFirstResponder()
        numberTf.resignFirstResponder()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                saveTaps: saveBun.rx.tap.asDriver(),
                doneTaps: doneBun.rx.tap.asDriver()
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
            .drive(onNext: { doneResult in
                switch doneResult {
                case .failed(let message):
                    self.showMessage(message)
                case .ok:
                    _ = self.navigationController?.popViewController(animated: true)
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)
    
      
        viewModel.doneEnabled
            .drive(onNext: { [weak self] valid in
                self?.doneBun.isEnabled = valid
                self?.doneBun.alpha = valid ? 1.0 : 0.5
            })
            .addDisposableTo(disposeBag)
        
        
        viewModel.doneResult?
            .drive(onNext: { doneResult in
                switch doneResult {
                case .failed(let message):
                    self.showMessage(message)
                case .ok:
                    self.performSegue(withIdentifier: R.segue.familyMemberAddController.showShareQRCode, sender: nil)
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)
        
    }
    
  

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sg = R.segue.familyMemberAddController.showShareQRCode(segue: segue) {
            sg.destination.relation = Relation(input: nameTf.text ?? "")?.transformIdentity()
            sg.destination.profile = self.viewModel.fid
            sg.destination.memberPhone = numberTf.text
        }
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
                self.numberTf.text = phones[0]
            }
        }
    }
    
    
    func showMessage(_ text: String) {
        let vc = UIAlertController.init(title: "提示", message: text, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        vc.addAction(action)
        self.present(vc, animated: true) {
            
        }
    }
    
    
}
