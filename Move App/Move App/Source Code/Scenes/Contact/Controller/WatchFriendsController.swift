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
    
    var disposeBag = DisposeBag()
    
    
    func setupUI() {
        deleteBun.isHidden = true
        
        let imgUrl = URL(string: FSManager.imageUrl(with: friendInfo?.profile ?? ""))
        photoImgV.kf.setImage(with: imgUrl, placeholder: R.image.relationship_ic_other()!)
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
        
    
        result
            .drive(onNext: { [weak self] rs in
                if rs.isValid {
                    _ = self?.navigationController?.popViewController(animated: true)
                }else{
                    print("failed")
                }
            })
            .addDisposableTo(disposeBag)
        
    }
    
    
    
    

}






