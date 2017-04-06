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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func unpairAction(_ sender: Any) {
        let manager = DeviceManager.shared
        manager.deleteDevice(with: (manager.currentDevice?.deviceId)!)
            .subscribe(onNext: { flag in
                self.dismiss(animated: true) {
                    if self.unpairBlock != nil {
                        self.unpairBlock!(flag, flag ? "unpaired success":"设备解绑失败")
                    }
                }
            }, onError: { er in
                print(er)
                self.dismiss(animated: true) {
                    if self.unpairBlock != nil {
                        self.unpairBlock!(false, "设备解绑失败")
                    }
                }
            }).addDisposableTo(disposeBag)
        
    }
    
 
    @IBAction func unpairCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    
}

