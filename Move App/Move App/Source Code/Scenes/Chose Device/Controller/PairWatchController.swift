//
//  PairWatchController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/13.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PairWatchController: UIViewController {
    
    var disposeBag = DisposeBag()

    @IBOutlet weak var scanBun: UIButton!
    @IBOutlet weak var tipBun: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    
    
    @IBOutlet weak var tipBottomCons: NSLayoutConstraint!
    
    private func initializeI18N() {
        scanBun.setTitle(R.string.localizable.id_scan_qr_code(), for: .normal)
        tipBun.setTitle(R.string.localizable.id_where_is_qr_cord(), for: .normal)
        skipBtn.setTitle(R.string.localizable.id_skip(), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeI18N()

        // Do any additional setup after loading the view.
        
        let screenH = UIScreen.main.bounds.height
        if screenH < 500 {
            tipBottomCons.constant = 10
        }else if screenH > 500 && screenH < 600 {
            tipBottomCons.constant = 20
        }else{
            tipBottomCons.constant = 30
        }
        
        let emptyOfLogin = AlertServer.share.emptyOfLoginVariable.asObservable()
        emptyOfLogin.map{!$0}.bindTo(skipBtn.rx.isHidden).addDisposableTo(disposeBag)
        emptyOfLogin.bindTo(backBtn.rx.isHidden).addDisposableTo(disposeBag)
        
        let skip = skipBtn.rx.tap.asDriver()
        skip.drive(onNext: {
                Distribution.shared.backToMainMap()
            })
            .addDisposableTo(disposeBag)
        skip.map{ false }.drive(AlertServer.share.emptyOfLoginVariable).addDisposableTo(disposeBag)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
}

