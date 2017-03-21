//
//  UnpairTipVC.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/21.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit


class UnpairTipVC: UIViewController {
    
    var unpairBlock: ((Bool, String) -> ())?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func unpairAction(_ sender: Any) {
        let manager = DeviceManager.shared
        _ = manager.deleteDevice(with: (manager.currentDevice?.deviceId)!).subscribe({ event in
            switch event {
            case .next(let flag):
                if self.unpairBlock != nil {
                    self.unpairBlock!(flag, flag ? "unpaired success":"设备解绑失败")
                }
            case .completed:
                self.dismiss(animated: true, completion: {
                })
            case .error(let er):
                print(er)
                self.dismiss(animated: true, completion: {
                })
                if self.unpairBlock != nil {
                    self.unpairBlock!(false, "设备解绑失败")
                }
                
            }
        })
        
    }
    
 
    @IBAction func unpairCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}

