//
//  WatchFriendsController.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/7.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WatchFriendsController: UIViewController {
    
    
    @IBOutlet weak var photoImgV: UIImageView!
    @IBOutlet weak var nameLab: UILabel!
    @IBOutlet weak var phoneLab: UILabel!
    
    @IBOutlet weak var deleteBun: UIButton!
    
    
    var friendInfo: DeviceFriend?
    
    
    func setupUI() {
        
        deleteBun.isHidden = true
        
        photoImgV.imageFromURL(FSManager.imageUrl(with: friendInfo?.profile ?? ""), placeholder: R.image.relationship_ic_other()!)
        nameLab.text = friendInfo?.nickname
        phoneLab.text = friendInfo?.phone
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        
        let manager = DeviceManager.shared
        
        let taps = deleteBun.rx.tap.asDriver()
        let result = taps.flatMapLatest({ _ -> SharedSequence<DriverSharingStrategy, ValidationResult> in
            return manager.deleteWatchFriend(deviceId: (manager.currentDevice?.deviceId)!, uid: (self.friendInfo?.uid)!)
                .map({ _ in
                    return ValidationResult.ok(message: "Delete success")
            }).asDriver(onErrorJustReturn: ValidationResult.failed(message: "Delete failed"))
        })
        
    
        result.drive(onNext: { rs in
            if rs.isValid {
                _ = self.navigationController?.popViewController(animated: true)
            }else{
                print("failed")
            }
        }, onCompleted: { 
            print("Completed")
        }).addDisposableTo(DisposeBag())
        
        
        
//        判断当前是否是管理员
        _ = DeviceManager.shared.getContacts(deviceId: (DeviceManager.shared.currentDevice?.deviceId)!).subscribe({ (event) in
            switch event {
            case .next(let cons):
                for con in cons {
                    if con.admin == true {
                        if UserInfo.shared.id == con.uid {
                            self.deleteBun.isHidden = false
                        }
                    }
                }
            case .completed:
                break
            case .error(let er):
                print(er)
            }
        })
        
    }
    
    
    
    

}






