//
//  KidInformationController.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/3.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation

class KidInformationController: UIViewController {
    
    @IBOutlet weak var cameraBun: UIButton!
    
    @IBOutlet weak var nextBun: UIButton!
    
    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var regionCodeBun: UIButton!
    @IBOutlet weak var phonePrefix: UILabel!
    @IBOutlet weak var phoneTf: UITextField!
    
    @IBOutlet weak var validateLab: UILabel!
    
    @IBOutlet weak var genderLab: UILabel!
    @IBOutlet weak var dateLab: UILabel!
    @IBOutlet weak var weightLab: UILabel!
    @IBOutlet weak var heightLab: UILabel!
    
    @IBOutlet weak var genderBun: UIButton!
    @IBOutlet weak var birthdayBun: UIButton!
    @IBOutlet weak var weightBun: UIButton!
    @IBOutlet weak var heightBun: UIButton!
    
    var isForSetting = false
    var isMaster = false//设置资料时，是否为管理员
    
    var addInfoVariable = Variable(DeviceBindInfo())
    
    var viewModel: KidInformationViewModel!
    var disposeBag = DisposeBag()
    
    var photoPicker: ImageUtility?
    var photoVariable:Variable<UIImage?> = Variable(nil)
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    func showvalidateError(_ text: String) {
        validateLab.isHidden = false
        validateLab.alpha = 0.0
        validateLab.text = text
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.validateLab.textColor = ValidationColors.errorColor
            self?.validateLab.alpha = 1.0
            self?.view.layoutIfNeeded()
        }
    }
    
    func revertvalidateError() {
        validateLab.isHidden = true
        validateLab.alpha = 1.0
        validateLab.text = ""
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.validateLab.textColor = ValidationColors.okColor
            self?.validateLab.alpha = 0.0
            self?.view.layoutIfNeeded()
        }
    }
    
    
    func  setupUI() {
        nextBun.setTitle(R.string.localizable.id_next(), for: .normal)
        
        validateLab.isHidden = true
        
        if isForSetting == true && isMaster == false {
            cameraBun.isEnabled = false
            nameTf.isEnabled = false
            regionCodeBun.isEnabled = false
            phoneTf.isEnabled = false
            
            genderBun.isEnabled = false
            birthdayBun.isEnabled = false
            weightBun.isEnabled = false
            heightBun.isEnabled = false
            
            nextBun.isHidden = true
        }
        
        var info = addInfoVariable.value
        
        if info.nickName == nil || info.nickName == "" {
            info.nickName = "baby"
            nameTf.text = "baby"
        }else{
            nameTf.text = info.nickName
        }
        
        let numberArr = info.number?.components(separatedBy: " ")
        if let arr = numberArr, arr.count > 1 {
            if let model = CountryCodeViewController.fetchCountryCode(with: arr[0]) {
                self.regionCodeBun.setTitle(model.abbr, for: .normal)
            }
            phonePrefix.text = arr[0]
            phoneTf.text = arr[1]
        }else{
            if let localModel = CountryCodeViewController.localCountryCode() {
                self.regionCodeBun.setTitle(localModel.abbr, for: .normal)
                self.phonePrefix.text = localModel.code
            }
            phoneTf.text = info.number
        }
        
        
        let imgUrl = URL(string: FSManager.imageUrl(with: info.profile ?? ""))
        cameraBun.kf.setBackgroundImage(with: imgUrl, for: .normal, placeholder: cameraBun.currentBackgroundImage!)
        
        
        
        if let gender = info.gender {
            genderLab.text = (gender == "0" ? R.string.localizable.id_male():R.string.localizable.id_female())
        }else{
            genderLab.text = R.string.localizable.id_gender()
        }
        
        if let height = info.height {
             heightLab.text =  "\(height) " + ((info.heightUnit == UnitType.metric) ? "cm":"inch")
        }else{
             heightLab.text = R.string.localizable.id_height()
        }
        
        if let weight = info.weight {
            weightLab.text =  "\(weight) " + ((info.weightUnit == UnitType.metric) ? "kg":"lb")
        }else{
            weightLab.text = R.string.localizable.id_weight()
        }
        
        if let birthday = info.birthday {
            dateLab.text =  birthday.stringYearMonthDay
        }else{
            dateLab.text = R.string.localizable.id_birthday()
        }
        
    }
    
    
    func cutString(_ text: String) -> String {
        var length = 0
        for char in text.characters {
            // 判断是否中文，是中文+2 ，不是+1
            length += "\(char)".lengthOfBytes(using: .utf8) == 3 ? 2 : 1
        }
        
        if length > 11 {
            let str = text.characters.dropLast()
            return cutString(String(str))
        }
        
        return text
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()

        
        let nameText = nameTf.rx.observe(String.self, "text").filterNil().asDriver(onErrorJustReturn: "")
        let nameDrier = nameTf.rx.text.orEmpty.asDriver()
        let combineName = Driver.of(nameText, nameDrier).merge()
        
        combineName.drive(onNext: {[weak self] name in
            if self?.nameTf.text != self?.cutString(name) {
                self?.nameTf.text = self?.cutString(name)
            }
        }).addDisposableTo(disposeBag)
        
        
        let phonePrefix = self.phonePrefix.rx.observe(String.self, "text").filterNil().asDriver(onErrorJustReturn: "")
        
        viewModel = KidInformationViewModel(
            input:(
                addInfo: addInfoVariable,
                photo: photoVariable,
                name: combineName,
                phonePrefix: phonePrefix,
                phone: phoneTf.rx.text.orEmpty.asDriver(),
                nextTaps: nextBun.rx.tap.asDriver()
            ),
            dependency: (
                deviceManager: DeviceManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        viewModel.isForSetting = isForSetting
        
        viewModel.nameValid.drive(onNext: {[weak self] result in
            switch result{
            case .failed(let message):
                self?.showvalidateError(message)
            default:
                self?.revertvalidateError()
            }
        }).addDisposableTo(disposeBag)
        
        viewModel.phoneValid.drive(onNext: {[weak self] result in
            switch result{
            case .failed(let message):
                self?.showvalidateError(message)
            default:
                self?.revertvalidateError()
            }
        }).addDisposableTo(disposeBag)
        
        
        viewModel.nextEnabled
            .drive(onNext: { [weak self] valid in
                self?.nextBun.isEnabled = valid
                self?.nextBun.alpha = valid ? 1.0 : 0.5
            })
            .addDisposableTo(disposeBag)
        
        
        viewModel.nextResult?
            .drive(onNext: {[weak self] doneResult in
                switch doneResult {
                case .failed(let message):
                    self?.showMessage(message)
                case .ok:
                    if self?.isForSetting == true {
                        _ = self?.navigationController?.popViewController(animated: true)
                    }else{
                        _ = self?.navigationController?.popToRootViewController(animated: true)
                    }
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    

    @IBAction func selectPhoto(_ sender: UIButton) {
        photoPicker = ImageUtility()
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "PhotoLibrary", style: .default) { _ in
            self.photoPicker?.selectPhoto(with: self, soureType: .photoLibrary, size: CGSize(width: 200, height: 200), callback: { (image) in
                self.cameraBun.setBackgroundImage(image, for: .normal)
                self.photoVariable.value = image
            })
        }
        let action2 = UIAlertAction(title: "Camera", style: .default) { _ in
            self.photoPicker?.selectPhoto(with: self, soureType: .camera, size: CGSize(width: 200, height: 200), callback: { (image) in
                self.cameraBun.setBackgroundImage(image, for: .normal)
                self.photoVariable.value = image
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
        
        self.present(vc, animated: true)
    }
    

    func showMessage(_ text: String) {
        let vc = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        vc.addAction(action)
        self.present(vc, animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = R.segue.kidInformationController.setGenderVC(segue: segue)?.destination  {
            vc.selectedGender = self.addInfoVariable.value.gender
            vc.genderBlock = { (gender) in
                self.addInfoVariable.value.gender = gender
                self.genderLab.text = (gender == "0" ? R.string.localizable.id_male():R.string.localizable.id_female())
            }
        }
        if let vc = R.segue.kidInformationController.setBirthdayVC(segue: segue)?.destination  {
            vc.selectedDate = self.addInfoVariable.value.birthday
            vc.birthdayBlock = { (birthday) in
                self.addInfoVariable.value.birthday = birthday
                self.dateLab.text = birthday.stringYearMonthDay
            }
        }
        if let vc = R.segue.kidInformationController.setWeightVC(segue: segue)?.destination {
            if let w = self.addInfoVariable.value.weight {
                vc.selectedWeight = w
            }
            if let unit = self.addInfoVariable.value.weightUnit {
                vc.isUnitKg = (unit == UnitType.metric) ? true:false
            }
            vc.weightBlock = { (weight, unit) in
                self.addInfoVariable.value.weight = weight
                self.addInfoVariable.value.weightUnit = unit
                self.weightLab.text = "\(weight) " + ((unit == UnitType.metric) ? "kg":"lb")
            }
        }
        if let vc = R.segue.kidInformationController.setHeightVC(segue: segue)?.destination {
            if let h = self.addInfoVariable.value.height {
                vc.selectedHeight = h
            }
            if let unit = self.addInfoVariable.value.heightUnit {
                vc.isUnitCm = (unit == UnitType.metric) ? true:false
            }
            vc.heightBlock = { (height, unit) in
                self.addInfoVariable.value.height = height
                self.addInfoVariable.value.heightUnit = unit
                self.heightLab.text = "\(height) " + ((unit == UnitType.metric) ? "cm":"inch")
            }
        }
        
        if let vc = R.segue.kidInformationController.showCountryCode(segue: segue)?.destination {
            vc.selectBlock = {model in
                self.regionCodeBun.setTitle(model.abbr, for: .normal)
                self.phonePrefix.text = model.code
            }
        }
        
        
        
        
    }
    
}







