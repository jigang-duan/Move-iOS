//
//  UnpairTipVC.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/21.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift


class UnpairTipVC: UIViewController {
    
    var unpairBlock: ((Bool, String) -> ())?
    
    var disposeBag = DisposeBag()
    
    var isMaster = false
    
    @IBOutlet weak var tipLab: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad() 
        
        if isMaster == true {
            tipLab.text = "As a master, unpaired with watch will factory reset the watch and all of the general user will also unpaired with watch"
        }else{
            tipLab.text = "You can't make a call with watch and can't receive notification or position from watch by unpaired with watch"
        }
        
    }
    
    @IBAction func unpairAction(_ sender: Any) {
        let manager = DeviceManager.shared
        manager.deleteDevice(with: (manager.currentDevice?.deviceId)!)
            .subscribe(onNext: { flag in
                self.dismiss(animated: true) {[weak self] _ in
                    if self?.unpairBlock != nil {
                        self?.unpairBlock!(flag, flag ? "Unpaired watch success":"Unpaired watch faild")
                    }
                }
            }, onError: { er in
                print(er)
                self.dismiss(animated: true) {[weak self] _ in
                    if self?.unpairBlock != nil {
                        self?.unpairBlock!(false, "Unpaired watch faild")
                    }
                }
            }).addDisposableTo(disposeBag)
        
    }
    
 
    @IBAction func unpairCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    
}

