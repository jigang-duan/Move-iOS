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
    
    @IBOutlet weak var masterBun: UIButton!
    @IBOutlet weak var deleteBun: UIButton!
    
    @IBOutlet weak var saveBun: UIBarButtonItem!
    
    var photoVariable:Variable<UIImage?> = Variable(nil)
    
    var info: ContactDetailInfo?
    
    var contactInfo = Variable(ImContact())
    
    var photoPicker: ImageUtility?
    
    
    var viewModel: FamilyMemberDetailViewModel!
    let disposeBag = DisposeBag()
    
    
    let addressbookHelper = AddressbookUtility()
    
    var isNowMaster: Bool{
        get{
            return UserInfo.shared.id == info?.contactInfo?.uid && (info?.isMaster)!
        }
    }
    
    struct ContactDetailInfo {
        var contactInfo: ImContact?
        var isMaster = false
        var isMe = false
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        nameTf.resignFirstResponder()
        numberTf.resignFirstResponder()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        
        contactInfo.value = (info?.contactInfo)!
        
        viewModel = FamilyMemberDetailViewModel(input:
            (
             photo: photoVariable,
             nameText: nameTf.rx.observe(String.self, "text"),
             name: nameTf.rx.text.orEmpty.asDriver(),
             numberText: numberTf.rx.observe(String.self, "text"),
             number: numberTf.rx.text.orEmpty.asDriver(),
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
                if self.isNowMaster == false && self.info?.isMe == false {
                    self.saveBun.isEnabled = false
                    self.saveBun.tintColor?.withAlphaComponent(0.5)
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
        if isNowMaster == false {
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
        }else if isNowMaster == true && info?.isMe == true {
            masterBun.isHidden = true
            deleteBun.isHidden = true
        }
        
        photoImgV.imageFromURL(FSManager.imageUrl(with: info?.contactInfo?.profile ?? ""), placeholder: R.image.relationship_ic_other()!)
        nameTf.text = info?.contactInfo?.identity?.description
        numberTf.text = info?.contactInfo?.phone
    }
    
    
    @IBAction func selectPhoto(_ sender: Any) {
        photoPicker = ImageUtility()
        photoPicker?.selectPhoto(with: self, callback: { (image) in
            self.photoImgV.image = image
            self.photoVariable.value = image
        }, size: CGSize(width: 100, height: 100))
    }
    

    @IBAction func selectRelation(_ sender: Any) {
        let vc = R.storyboard.main.relationshipTableController()!
        vc.relationBlock = {[weak self] relation in
            self?.viewModel.contactInfo?.value.identity = Relation(input: String(relation + 1))
            self?.nameTf.text =  self?.viewModel.contactInfo?.value.identity?.description
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

