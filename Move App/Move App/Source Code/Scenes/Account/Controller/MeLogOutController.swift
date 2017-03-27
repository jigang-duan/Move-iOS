//
//  MeLogoutController.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/9.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import CustomViews
import Kingfisher
import RxCocoa
import RxSwift

class MeLogoutController: UIViewController {
    
    
    @IBOutlet weak var nameLab: UILabel!
    @IBOutlet weak var headBun: UIButton!
    @IBOutlet weak var logoutBun: UIButton!
    
    var disposeBag = DisposeBag()
    var viewModel: MeLogoutViewModel!
    
    typealias SaveData = (String?, Int?, Int?, Date?, UIImage?)
    var saveSubject = PublishSubject<SaveData>()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let info = UserInfo.shared.profile
        
        nameLab.text = info?.nickname
        let placeImg = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: headBun.frame.width, height: headBun.frame.height), fullName: info?.nickname ?? "").imageRepresentation()!
        headBun.setBackgroundImage(placeImg, for: .normal)
        
        self.updateAvatar(with: info?.iconUrl ?? "")
    }
    
    
    func  updateAvatar(with url: String) {
        if url == "" { return }
        let imgUrl = URL(string: FSManager.imageUrl(with: url))
        headBun.kf.setBackgroundImage(with: imgUrl, for: .normal, placeholder: headBun.currentBackgroundImage!)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        viewModel = MeLogoutViewModel(
            input: logoutBun.rx.tap.asDriver(),
            dependency: (
                userManager: UserManager.shared,
                wireframe: DefaultWireframe.sharedInstance
        ))
        
        viewModel.logoutEnabled
            .drive(onNext: { [unowned self] valid in
                self.logoutBun.isEnabled = valid
                self.logoutBun.tintColor?.withAlphaComponent(valid ? 1.0 : 0.5)
            })
            .addDisposableTo(disposeBag)
        
        
        
        viewModel.logoutResult
            .drive(onNext: { [unowned self] result in
                switch result {
                case .failed(let message):
                    self.showMessage(message)
                case .ok:
                    UserInfo.shared.invalidate()
                    UserInfo.shared.profile = nil
                    Distribution.shared.popToLoginScreen()
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)
        
//        saveSubject.asDriver(onErrorJustReturn: (nil,nil,nil,nil,nil))
//            .flatMapLatest({
//                var info = UserInfo.Profile()
//                info.gender = $0.0
//                info.weight = $0.2
//                info.height = $0.1
//                info.birthday = $0.3
//            })
        
    }
    
    func showMessage(_ text: String) {
        let vc = UIAlertController.init(title: "提示", message: text, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        vc.addAction(action)
        self.present(vc, animated: true) {
            
        }
    }
    
    
    @IBAction func headClick(_ sender: Any) {
        self.performSegue(withIdentifier: R.segue.meLogoutController.shwoMeSettings, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sg = R.segue.meLogoutController.shwoMeSettings(segue: segue) {
            sg.destination.settingSaveBlock = { gender, height, weight, birthday, changedImage in
                
                var info = UserInfo.Profile()
                info.gender = gender
                info.weight = weight
                info.height = height
                info.birthday = birthday
                
                
                var result: Observable<ValidationResult>?
                if changedImage != nil {
                    result = FSManager.shared.uploadPngImage(with: changedImage!).map{$0.fid}.filterNil().flatMap({fid ->Observable<ValidationResult> in
                        info.iconUrl = fid
                        return self.settingUserInfo(with: info)
                    })
                }else {
                    result = self.settingUserInfo(with: info)
                }
                
                result?.subscribe({ event in
                    switch event{
                    case .next(let value):
                        print(value)
                    case .completed:
                        UserInfo.shared.profile?.gender = info.gender
                        UserInfo.shared.profile?.height = info.height
                        UserInfo.shared.profile?.weight = info.weight
                        UserInfo.shared.profile?.birthday = info.birthday
                        if changedImage != nil {
                            UserInfo.shared.profile?.iconUrl = info.iconUrl
                            self.updateAvatar(with: info.iconUrl ?? "")
                        }
                    case .error(let error):
                        print(error)
                    }
                }).addDisposableTo(self.disposeBag)
            }
        }
    }
    
    
    
    func settingUserInfo(with info: UserInfo.Profile) -> Observable<ValidationResult>{
        return UserManager.shared.setUserInfo(userInfo: info).map{ flag -> ValidationResult in
            if flag {
                return ValidationResult.ok(message: "OK")
            }else{
                return ValidationResult.failed(message: "failed")
            }
        }
    }
    
    
}

