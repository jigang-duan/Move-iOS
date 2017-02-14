//
//  LoginViewController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    let error = true
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var errorTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var emailLineView: UIView!
    @IBOutlet weak var accountErrorLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func showAccountError(_ text: String) {
        //当帐号不存在de时候
        if error {
            errorTopConstraint.constant = 30
            accountErrorLabel.isHidden = false
            accountErrorLabel.alpha = 0.0
            UIView.animate(withDuration: 0.6) { [weak self] in
                self?.emailLineView.backgroundColor = R.color.appColor.wrong()
                self?.accountErrorLabel.alpha = 1.0
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loginBtn.rx.tap
            .bindNext { [weak self] in
                self?.showAccountError("")
            }
            .addDisposableTo(disposeBag)
    }
    
    
}
