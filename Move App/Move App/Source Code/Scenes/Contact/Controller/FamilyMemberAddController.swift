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

class FamilyMemberAddController: UIViewController {
    
    
    @IBOutlet weak var saveBun: UIBarButtonItem!
    @IBOutlet weak var photoImgV: UIImageView!
    
    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var numberTf: UITextField!
    
    @IBOutlet weak var doneBun: UIButton!

    
    var viewModel: FamilyMemberAddViewModel!
    var disposeBag = DisposeBag()


    
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
        
        
        viewModel = FamilyMemberAddViewModel(
            input:(
                name: nameTf.rx.text.orEmpty.asDriver(),
                number: numberTf.rx.text.orEmpty.asDriver(),
                doneTaps: doneBun.rx.tap.asDriver()
            ),
            dependency: (
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
    
      
        viewModel.doneEnabled
            .drive(onNext: { [weak self] valid in
                self?.doneBun.isEnabled = valid
                self?.doneBun.alpha = valid ? 1.0 : 0.5
            })
            .addDisposableTo(disposeBag)
        
        
        viewModel.doneResult?
            .drive(onNext: { doneResult in
                switch doneResult {
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
            sg.destination.memberName = nameTf.text
            sg.destination.memberPhone = numberTf.text
            if let rl = Int(nameTf.text!) {
                if rl >= 1 && rl <= 10 {
                     sg.destination.relation = String(rl)
                }
            }else{
                sg.destination.relation = nameTf.text
            }
        }
    }
    
    
    @IBAction func selectPhoto(_ sender: Any) {
        if cameraPermissions() {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = true
            imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }else{
            self.showMessage("没有相机权限")
        }
    }
    
    func cameraPermissions() -> Bool{
        let authStatus:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if(authStatus == AVAuthorizationStatus.denied || authStatus == AVAuthorizationStatus.restricted) {
            return false
        }
        return true
    }
    
    @IBAction func selectRelation(_ sender: Any) {
        let vc = R.storyboard.main.relationshipTableController()!
        vc.relationBlock = {[weak self] relation in
            self?.nameTf.text =  Relation(input: String(relation + 1))?.description
        }
        self.navigationController?.show(vc, sender: nil)
    }
    
    
    @IBAction func selectPhone(_ sender: Any) {
        
        
    }
    
    
    
    
    
    func showMessage(_ text: String) {
        let vc = UIAlertController.init(title: "提示", message: text, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        vc.addAction(action)
        self.present(vc, animated: true) {
            
        }
    }
    
    
}

extension FamilyMemberAddController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.photoImgV.image = image
        }
        picker.dismiss(animated: true) { 
            
        }
    }
    

}


extension FamilyMemberAddController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
}


