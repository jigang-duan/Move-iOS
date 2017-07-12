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
    @IBOutlet weak var photoLab: UILabel!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var numberLab: UILabel!
    
    @IBOutlet weak var selectPhotoBun: UIButton!
    @IBOutlet weak var selectRelationBun: UIButton!
    @IBOutlet weak var selectPhoneBun: UIButton!
    
    @IBOutlet weak var photoImgV: UIImageView!
    
    @IBOutlet weak var identityLab: UILabel!
    @IBOutlet weak var numberTf: UITextField!
    
    
    @IBOutlet weak var validateLab: UILabel!
    
    @IBOutlet weak var masterBun: UIButton!
    @IBOutlet weak var masterHCons: NSLayoutConstraint!
    @IBOutlet weak var deleteBun: UIButton!
    
    @IBOutlet weak var saveBun: UIBarButtonItem!
    
    //未注册用户
    @IBOutlet weak var noRegisterTipLab: UILabel!
    @IBOutlet weak var noRegisterTipLabHCons: NSLayoutConstraint!
    
    
    @IBOutlet weak var countryCodeBun: UIButton!
    @IBOutlet weak var phonePreLab: UILabel!
    
    private var photoVariable:Variable<UIImage?> = Variable(nil)
    private var identityVariable:Variable<Relation?> = Variable(nil)
    
    var info: ContactDetailInfo?
    
    private var contactInfo = Variable(ImContact())
    
    private var photoPicker: ImageUtility?
    private let addressbookHelper = AddressbookUtility()
    
    private let disposeBag = DisposeBag()
    
    var masterInfo: ImContact?//管理员信息,用于转让管理员时取消自己紧急联系人身份
    
    
    struct ContactDetailInfo {
        var contactInfo: ImContact?
        var isNowMaster = false
        var isMe = false
    }
    
    
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
        noRegisterTipLab.text = R.string.localizable.id_not_usp_app()
        masterBun.setTitle(R.string.localizable.id_set_as_master(), for: .normal)
        deleteBun.setTitle(R.string.localizable.id_str_remove_alarm_title(), for: .normal)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeI18N()
        
        validateLab.text = nil
        
        self.setupUI()
        
        
        contactInfo.value = (info?.contactInfo)!
        
        
        let masterTap = Variable(false)
        masterBun.rx.tap.asObservable()
            .bindNext {
                let vc = UIAlertController(title: nil, message: R.string.localizable.id_sure_as_master(), preferredStyle: .alert)
                let action1 = UIAlertAction(title: R.string.localizable.id_yes(), style: .default){ _ in
                    masterTap.value = true
                }
                let action2 = UIAlertAction(title: R.string.localizable.id_cancel(), style: .default)
                vc.addAction(action1)
                vc.addAction(action2)
                self.present(vc, animated: true)
            }
            .addDisposableTo(disposeBag)
        
        let deleteTap = Variable(false)
        deleteBun.rx.tap.asObservable()
            .bindNext {
                let vc = UIAlertController(title: nil, message: R.string.localizable.id_delete_description(), preferredStyle: .alert)
                let action1 = UIAlertAction(title: R.string.localizable.id_yes(), style: .default){ _ in
                    deleteTap.value = true
                }
                let action2 = UIAlertAction(title: R.string.localizable.id_cancel(), style: .default)
                vc.addAction(action1)
                vc.addAction(action2)
                self.present(vc, animated: true)
            }
            .addDisposableTo(disposeBag)
        
        let phonePrefix = self.phonePreLab.rx.observe(String.self, "text").filterNil().asDriver(onErrorJustReturn: "")
        
        let numberText = numberTf.rx.observe(String.self, "text").filterNil().asDriver(onErrorJustReturn: "")
        let numberDriver = numberTf.rx.text.orEmpty.asDriver()
        let comNumber = Driver.of(numberText,numberDriver).merge()
        
        let viewModel = FamilyMemberDetailViewModel(input:
            (
             photo: photoVariable,
             name: identityVariable,
             phonePrefix: phonePrefix,
             number: comNumber,
             masterTaps: masterTap.asDriver(),
             deleteTaps: deleteTap.asDriver(),
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
        
        viewModel.masterInfo = masterInfo
        
        
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
                switch result {
                case .failed(let message):
                    self.showMessage(message)
                case .ok:
                    _ = self.navigationController?.popToRootViewController(animated: true)
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)
        
        viewModel.deleteResult?
            .drive(onNext: { [unowned self] result in
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
            noRegisterTipLab.isHidden = true
            noRegisterTipLabHCons.constant = 0
            
            masterBun.isHidden = true
            deleteBun.isHidden = true
            if info?.isMe == false {
                selectPhotoBun.isHidden = true
                selectRelationBun.isHidden = true
                selectPhoneBun.isHidden = true
                numberTf.isEnabled = false
                saveBun.isEnabled = false
            }
        }else{
            if info?.isMe == true {
                masterBun.isHidden = true
                deleteBun.isHidden = true
            }
           
            if info?.contactInfo?.type == 1 {
                noRegisterTipLab.isHidden = true
                noRegisterTipLabHCons.constant = 0
            }else{
                masterBun.isHidden = true
                masterHCons.constant = 0
            }
        }
        
        let imgUrl = URL(string: FSManager.imageUrl(with: info?.contactInfo?.profile ?? ""))
        photoImgV.kf.setImage(with: imgUrl, placeholder: R.image.relationship_ic_other()!)
        identityLab.text = info?.contactInfo?.identity?.description
        identityVariable.value = info?.contactInfo?.identity
        
        let numberArr = info?.contactInfo?.phone?.components(separatedBy: "@")
        if let arr = numberArr, arr.count > 1 {
            if let model = CountryCodeViewController.fetchCountryCode(with: arr[0]) {
                self.countryCodeBun.setTitle(model.abbr, for: .normal)
            }
            phonePreLab.text = arr[0]
            numberTf.text = arr[1]
        }else{
            self.countryCodeBun.setTitle("-", for: .normal)
            phonePreLab.text = "-"
            numberTf.text = info?.contactInfo?.phone
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
        let action2 = UIAlertAction(title: R.string.localizable.id_select_image(), style: .default) { _ in
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
        vc.relationBlock = {[weak self] relation in
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
            }
        }
    }
    
    //    选择国家代号
    @IBAction func selectCountryCode(_ sender: UIButton) {
        let vc = R.storyboard.kidInformation.countryCodeViewController()!
        vc.selectBlock = { [weak self] model in
            self?.countryCodeBun.setTitle(model.abbr, for: .normal)
            self?.phonePreLab.text = model.code
        }
        self.navigationController?.show(vc, sender: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        numberTf.resignFirstResponder()
    }
    
    func showMessage(_ text: String) {
        UIView.animate(withDuration: 0.3) { 
            self.validateLab.isHidden = false
            self.validateLab.text = text
            self.view.layoutIfNeeded()
        }
    }
    
    
}

