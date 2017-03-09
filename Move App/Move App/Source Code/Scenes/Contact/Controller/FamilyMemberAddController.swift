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

class FamilyMemberAddController: UIViewController {
    
    
    @IBOutlet weak var saveBun: UIBarButtonItem!
    @IBOutlet weak var photoImgV: UIImageView!
    
    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var numberTf: UITextField!
    @IBOutlet weak var selectNumberBun: UIButton!
    
    @IBOutlet weak var doneBun: UIButton!
    
    var identityVaraiable = Variable(0)
    
    let photos = ["relationship_ic_mun","relationship_ic_dad","relationship_ic_grandma","relationship_ic_grandpa","relationship_ic_grandma","relationship_ic_grandpa","relationship_ic_aunt","relationship_ic_uncle","relationship_ic_brother","relationship_ic_sister","relationship_ic_other"]
    
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
                identity: identityVaraiable.asDriver(),
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
            sg.destination.relation = String(describing: identityVaraiable.value)
        }
    }
    
    @IBAction func selectPhoto(_ sender: Any) {
        let vc = R.storyboard.main.relationshipTableController()!
        vc.relationBlock = { relation in
            self.identityVaraiable.value = relation
            self.photoImgV.image = UIImage(named: self.photos[relation - 1])
        }
        self.navigationController?.show(vc, sender: nil)
    }
    
}

extension FamilyMemberAddController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
}


