//
//  ProtectAccountController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/11.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ProtectAccountController: UIViewController {
    
    @IBOutlet weak var HelpLabel: UILabel!
    @IBOutlet weak var vcodeTf: UITextField!
    @IBOutlet weak var sendBun: UIButton!
    @IBOutlet weak var vcodeValidation: UILabel!
    @IBOutlet weak var doneBun: UIButton!
    
    public var email: String?
    
    var viewModel: ProtectAccountViewModel!
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        HelpLabel.text = "Help us protect your.The verification\ncode was sent to your Email\n\(email)."
        
        
        viewModel = ProtectAccountViewModel(
            input:(
                vcode: vcodeTf.rx.text.orEmpty.asDriver(),
                sendTaps: sendBun.rx.tap.asDriver(),
                doneTaps: doneBun.rx.tap.asDriver()
            ),
            dependency: (
                userManager: UserManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        viewModel.sendEnabled
            .drive(onNext: { [weak self] valid in
                self?.sendBun.isEnabled = valid
                self?.sendBun.alpha = valid ? 1.0 : 0.5
            })
            .addDisposableTo(disposeBag)
        
        viewModel.doneEnabled
            .drive(onNext: { [weak self] valid in
                self?.doneBun.isEnabled = valid
                self?.doneBun.alpha = valid ? 1.0 : 0.5
            })
            .addDisposableTo(disposeBag)
        
//        viewModel.sendResult
//            .drive(onNext: { sendResult in
//                switch sendResult {
//                case .failed(let message):
//                    self.showAccountError(message)
//                    self.gotoProtectVC()
//                case .ok:
//                self.gotoProtectVC()
//                default:
//                    break
//                }
//            })
//            .addDisposableTo(disposeBag)
        
        
        viewModel.doneResult
            .drive(onNext: { doneResult in
                switch doneResult {
                case .failed(let message):
                    self.vcodeValidation.text = message
                    self.vcodeValidation.isHidden = false
                case .ok:
                    _ = self.navigationController?.popViewController(animated: true)
                default:
                    self.vcodeValidation.isHidden = true
                }
            })
            .addDisposableTo(disposeBag)
        
    }
    

    
    
    
    
    @IBAction func BackAction(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension ProtectAccountController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
