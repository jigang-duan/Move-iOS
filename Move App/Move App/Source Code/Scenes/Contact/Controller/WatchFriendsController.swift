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
    @IBOutlet weak var photoTip: UILabel!
    @IBOutlet weak var nameTip: UILabel!
    @IBOutlet weak var numberTip: UILabel!
    
    @IBOutlet weak var photoImgV: UIImageView!
    @IBOutlet weak var nameLab: UILabel!
    @IBOutlet weak var phoneLab: UILabel!
    
    @IBOutlet weak var deleteBun: UIButton!
    
    let deleteSubject = PublishSubject<Void>()
    
    var friendInfo: DeviceFriend?
    
    var disposeBag = DisposeBag()
    
    
    func setupUI() {
        
        let imgUrl = URL(string: FSManager.imageUrl(with: friendInfo?.profile ?? ""))
        photoImgV.kf.setImage(with: imgUrl, placeholder: R.image.relationship_ic_other()!)
        nameLab.text = friendInfo?.nickname
        phoneLab.text = friendInfo?.phone?.replacingOccurrences(of: "@", with: " ")
    }
    
    private func initializeI18N() {
        self.title = R.string.localizable.id_watch_friends()
        
        photoTip.text = R.string.localizable.id_photo()
        nameTip.text = R.string.localizable.id_name()
        numberTip.text = R.string.localizable.id_number()
        
        deleteBun.setTitle(R.string.localizable.id_str_remove_alarm_title(), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeI18N()
        
        self.setupUI()
        
        
        
        let manager = DeviceManager.shared
        
        deleteBun.rx.tap.asObservable()
            .bindNext { [weak self] in
                let vc = UIAlertController(title: nil, message: "Delete this friend?", preferredStyle: .alert)
                let action1 = UIAlertAction(title: R.string.localizable.id_cancel(), style: .default)
                let action2 = UIAlertAction(title: R.string.localizable.id_yes(), style: .default){ _ in
                    self?.deleteSubject.onNext()
                }
                vc.addAction(action1)
                vc.addAction(action2)
                self?.present(vc, animated: true)
            }
            .addDisposableTo(disposeBag)
    
        
        deleteSubject.asDriver(onErrorJustReturn: ())
            .flatMapLatest({ _ -> Driver<ValidationResult> in
                manager.deleteWatchFriend(deviceId: (manager.currentDevice?.deviceId)!, uid: (self.friendInfo?.uid)!)
                    .map({ _ in
                        ValidationResult.ok(message: "Delete success")
                    })
                    .asDriver(onErrorJustReturn: ValidationResult.failed(message: "Delete failed"))
            })
            .drive(onNext: { [weak self] rs in
                if rs.isValid {
                    _ = self?.navigationController?.popViewController(animated: true)
                }else{
                    print("Delete watch friend failed")
                }
            })
            .addDisposableTo(disposeBag)
        
    
        
        
    }
    
    
    
    

}






