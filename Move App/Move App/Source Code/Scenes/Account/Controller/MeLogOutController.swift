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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let info = UserInfo.shared.profile
        
        nameLab.text = info?.nickname
        let placeImg = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: headBun.frame.width, height: headBun.frame.height), fullName: info?.nickname ?? "").imageRepresentation()!
       
        var imgResouce: ImageResource?
        if let imgUrl = URL(string: info?.iconUrl ?? "") {
            imgResouce = ImageResource(downloadURL: imgUrl)
        }
        headBun.kf.setBackgroundImage(with: imgResouce, for: UIControlState.normal, placeholder: placeImg)
        
        
        
        
        
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
                    UserInfo.shared.accessToken = UserInfo.AccessToken()
                    UserInfo.shared.id = nil
                    UserInfo.shared.profile = nil
                    self.present(R.storyboard.login.instantiateInitialViewController()!, animated: true, completion: nil)
                    _ = self.navigationController?.popToRootViewController(animated: true)
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)

        
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
            sg.destination.settingSaveBlock = { gender, height, weight, birthday in
                var info = UserInfo.Profile()
                info.gender = gender
                info.weight = weight
                info.height = height
                info.birthday = birthday
                _ = UserManager.shared.setUserInfo(userInfo: info).subscribe({ (event) in
                    switch event{
                    case .next(let value):
                        print(value)
                    case .completed:
                        UserInfo.shared.profile?.gender = gender
                        UserInfo.shared.profile?.height = height
                        UserInfo.shared.profile?.weight = weight
                        UserInfo.shared.profile?.birthday = birthday
                    case .error(let error):
                        print(error)
                    }
                })
            }
        }
    }
    
    
}

