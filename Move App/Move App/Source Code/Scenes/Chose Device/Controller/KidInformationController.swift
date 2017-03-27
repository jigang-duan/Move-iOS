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
    @IBOutlet weak var phoneTf: UITextField!
    
    @IBOutlet weak var genderLab: UILabel!
    @IBOutlet weak var dateLab: UILabel!
    @IBOutlet weak var weightLab: UILabel!
    @IBOutlet weak var heightLab: UILabel!
    
    
    var isForSetting: Bool?
    
    var deviceAddInfo: DeviceBindInfo?
    
    var viewModel: KidInformationViewModel!
    var disposeBag = DisposeBag()
    
    var photoPicker: ImageUtility?
    
    var photoVariable:Variable<UIImage?> = Variable(nil)
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    
    func  setupUI() {
        if deviceAddInfo?.nickName == nil {
            deviceAddInfo?.nickName = "baby"
            nameTf.text = "baby"
        }else{
            nameTf.text = deviceAddInfo?.nickName
        }
        
        phoneTf.text = deviceAddInfo?.number
        
        
        let imgUrl = URL(string: FSManager.imageUrl(with: deviceAddInfo?.profile ?? ""))
        cameraBun.kf.setBackgroundImage(with: imgUrl, for: .normal, placeholder: cameraBun.currentBackgroundImage!)
        
        
        genderLab.text = deviceAddInfo?.gender ?? "Gender"
        if let height = deviceAddInfo?.height {
             heightLab.text =  "\(height) cm"
        }else{
             heightLab.text = "Height"
        }
        
        if let weight = deviceAddInfo?.weight {
            weightLab.text =  "\(weight) kg"
        }else{
            weightLab.text = "Weight"
        }
        
        if let birthday = deviceAddInfo?.birthday {
            dateLab.text =  birthday.stringYearMonthDay
        }else{
            dateLab.text = "Birthday"
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        
        viewModel = KidInformationViewModel(
            input:(
                photo: photoVariable,
                name: nameTf.rx.text.orEmpty.asDriver(),
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
        
        viewModel.addInfo = self.deviceAddInfo
        
        viewModel.nextEnabled
            .drive(onNext: { [weak self] valid in
                self?.nextBun.isEnabled = valid
                self?.nextBun.alpha = valid ? 1.0 : 0.5
            })
            .addDisposableTo(disposeBag)
        
        
        viewModel.nextResult?
            .drive(onNext: {[unowned self] doneResult in
                switch doneResult {
                case .failed(let message):
                    self.showMessage(message)
                case .ok(_):
                    for vc in (self.navigationController?.viewControllers)! {
                        if vc.isKind(of: ChoseDeviceController.self) {
                            _ = self.navigationController?.popToRootViewController(animated: true)
                            return
                        }
                    }
                    _ = self.navigationController?.popViewController(animated: true)
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    

    @IBAction func selectPhoto(_ sender: Any) {
        photoPicker = ImageUtility()
        photoPicker?.selectPhoto(with: self, soureType: .photoLibrary, size: CGSize(width: 200, height: 200), callback: { (image) in
            self.cameraBun.setBackgroundImage(image, for: UIControlState.normal)
            self.photoVariable.value = image
        })
    }
    

    func showMessage(_ text: String) {
        let vc = UIAlertController.init(title: "提示", message: text, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        vc.addAction(action)
        self.present(vc, animated: true) {
            
        }
    }
    
    
    @IBAction func genderAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: R.segue.kidInformationController.setGenderVC, sender: nil)
    }
    
    @IBAction func birthdayAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: R.segue.kidInformationController.setBirthdayVC, sender: nil)
    }
    
    @IBAction func weightAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: R.segue.kidInformationController.setWeightVC, sender: nil)
    }
    
    @IBAction func heightAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: R.segue.kidInformationController.setHeightVC, sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sg = R.segue.kidInformationController.setGenderVC(segue: segue) {
            sg.destination.genderBlock = { (gender) in
                self.deviceAddInfo?.gender = gender
                self.genderLab.text = gender
                self.viewModel.addInfo = self.deviceAddInfo
            }
        }
        if let sg = R.segue.kidInformationController.setBirthdayVC(segue: segue) {
            sg.destination.birthdayBlock = { (birthday) in
                self.deviceAddInfo?.birthday = birthday
                self.dateLab.text = birthday.stringYearMonthDay
                self.viewModel.addInfo = self.deviceAddInfo
            }
        }
        if let sg = R.segue.kidInformationController.setWeightVC(segue: segue) {
            sg.destination.weightBlock = { (weight) in
                self.deviceAddInfo?.weight = weight
                self.weightLab.text = "\(weight) kg"
                self.viewModel.addInfo = self.deviceAddInfo
            }
        }
        if let sg = R.segue.kidInformationController.setHeightVC(segue: segue) {
            sg.destination.heightBlock = { (height) in
                self.deviceAddInfo?.height = height
                self.heightLab.text = "\(height) cm"
                self.viewModel.addInfo = self.deviceAddInfo
            }
        }
    }
    
}







