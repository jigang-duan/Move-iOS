//
//  FamilyMemberDetailController.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/7.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation


class FamilyMemberDetailController: UIViewController {
    
    
    @IBOutlet weak var selectPhotoBun: UIButton!
    @IBOutlet weak var selectRelationBun: UIButton!
    @IBOutlet weak var selectPhoneBun: UIButton!
    
    @IBOutlet weak var photoImgV: UIImageView!
    
    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var numberTf: UITextField!
    
    @IBOutlet weak var qrCodeView: UIView!
    @IBOutlet weak var qrCodeHCons: NSLayoutConstraint!
    
    
    
    @IBOutlet weak var masterBun: UIButton!
    @IBOutlet weak var masterHCons: NSLayoutConstraint!
    @IBOutlet weak var deleteBun: UIButton!
    
    @IBOutlet weak var saveBun: UIBarButtonItem!
    
    private var photoVariable:Variable<UIImage?> = Variable(nil)
    
    var info: ContactDetailInfo?
    
    var exsitIdentities: [Relation] = []
    
    private var contactInfo = Variable(ImContact())
    
    private var photoPicker: ImageUtility?
    
    
    private var viewModel: FamilyMemberDetailViewModel!
    private let disposeBag = DisposeBag()
    
    
    private let addressbookHelper = AddressbookUtility()
    
    
    struct ContactDetailInfo {
        var contactInfo: ImContact?
        var isNowMaster = false
        var isMe = false
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
       self.view.endEditing(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        
        contactInfo.value = (info?.contactInfo)!
        
        let name = nameTf.rx.text.orEmpty.asDriver()
        let nameText = nameTf.rx.observe(String.self, "text").filterNil()
        let combineName = Driver.of(nameText.asDriver(onErrorJustReturn: ""), name).merge()
        
        let number = numberTf.rx.text.orEmpty.asDriver()
        let numberText = numberTf.rx.observe(String.self, "text").filterNil()
        let combineNumber = Driver.of(numberText.asDriver(onErrorJustReturn: ""), number).merge()
        
        viewModel = FamilyMemberDetailViewModel(input:
            (
             photo: photoVariable,
             name: combineName,
             number: combineNumber,
             masterTaps: masterBun.rx.tap.asDriver(),
             deleteTaps: deleteBun.rx.tap.asDriver(),
             saveTaps: saveBun.rx.tap.asDriver()
            ),
             dependency:
            (
             deviceManager: DeviceManager.shared,
             validation: DefaultValidation.shared,
             wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        viewModel.contactInfo = contactInfo
        
        
        
        
        viewModel.saveEnabled?
            .drive(onNext: { [unowned self] valid in
                if self.info?.isNowMaster == false && self.info?.isMe == false {
                    self.navigationItem.rightBarButtonItem = nil
                }else{
                    self.saveBun.isEnabled = valid
                    self.saveBun.tintColor?.withAlphaComponent(valid ? 1.0 : 0.5)
                }
            })
            .addDisposableTo(disposeBag)
        
        
        
        viewModel.masterResult?
            .drive(onNext: { [unowned self] result in
                self.nameTf.resignFirstResponder()
                switch result {
                case .failed(let message):
                    self.showMessage(message)
                case .ok:
                    _ = self.navigationController?.popViewController(animated: true)
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)
        
        viewModel.deleteResult?
            .drive(onNext: { [unowned self] result in
                self.nameTf.resignFirstResponder()
                switch result {
                case .failed(let message):
                    self.showMessage(message)
                case .ok:
                    _ = self.navigationController?.popViewController(animated: true)
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)
        
        viewModel.saveResult?
            .drive(onNext: { [unowned self] result in
                self.nameTf.resignFirstResponder()
                switch result {
                case .failed(let message):
                    self.showMessage(message)
                case .ok:
                    _ = self.navigationController?.popViewController(animated: true)
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)

        
    }
    
    
    func setupUI() {
        if self.info?.isNowMaster == false {
            qrCodeView.isHidden = true
            qrCodeHCons.constant = 0
            
            masterBun.isHidden = true
            deleteBun.isHidden = true
            if info?.isMe == false {
                selectPhotoBun.isHidden = true
                selectRelationBun.isHidden = true
                selectPhoneBun.isHidden = true
                nameTf.isEnabled = false
                numberTf.isEnabled = false
                saveBun.isEnabled = false
            }
        }else{
            if info?.isMe == true {
                masterBun.isHidden = true
                deleteBun.isHidden = true
            }
           
            if info?.contactInfo?.type == 1 {
                qrCodeView.isHidden = true
                qrCodeHCons.constant = 0
            }else{
                masterBun.isHidden = true
                masterHCons.constant = 0
            }
        }
        
        let imgUrl = URL(string: FSManager.imageUrl(with: info?.contactInfo?.profile ?? ""))
        photoImgV.kf.setImage(with: imgUrl, placeholder: R.image.relationship_ic_other()!)
        nameTf.text = info?.contactInfo?.identity?.description
        numberTf.text = info?.contactInfo?.phone
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
            self?.nameTf.text = relation.description
            self?.viewModel.contactInfo?.value.identity = relation
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = R.segue.familyMemberDetailController.showShareQRcode(segue: segue)?.destination {
            vc.profile = viewModel.contactInfo?.value.profile
            vc.relation = viewModel.contactInfo?.value.identity?.description
            vc.memberPhone = viewModel.contactInfo?.value.phone
        }
    }
    
    
    func showMessage(_ text: String) {
        let vc = UIAlertController(title: "提示", message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        vc.addAction(action)
        self.present(vc, animated: true)
    }
    
    
}

