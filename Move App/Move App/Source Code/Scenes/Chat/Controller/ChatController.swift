//
//  ChatController.swift
//  Move App
//
//  Created by yinxiao on 2017/3/24.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ChatController: UIViewController {
    
    @IBOutlet weak var segmentedOutlet: UISegmentedControl!
    @IBOutlet weak var familyChatView: UIView!
    @IBOutlet weak var singleChatView: UIView!
    
    var disposeBag = DisposeBag()
    
    var guideimageView = UIImageView()
    
    @IBOutlet weak var chatIconBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.showGuide()
        
        segmentedOutlet.setTitle(DeviceManager.shared.currentDevice?.user?.nickname, forSegmentAt: 1)
        
        segmentedOutlet.rx.selectedSegmentIndex
            .asDriver()
            .map({ $0 != 0 })
            .drive(familyChatView.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        segmentedOutlet.rx.selectedSegmentIndex
            .asDriver()
            .map({ $0 != 1 })
            .drive(singleChatView.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        segmentedOutlet.rx.selectedSegmentIndex.asDriver()
            .drive(chatIconBtn.rx.selectedSegmentIndex)
            .addDisposableTo(disposeBag)
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ChatController {
        
    fileprivate func showGuide() {
        
        if Preferences.shared.mkChatFirst {
            //引导
            guideimageView = UIImageView(image: R.image.message_friendsuser_guide())
            guideimageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            let window = UIApplication.shared.keyWindow
            window?.addSubview(guideimageView)
            guideimageView.isUserInteractionEnabled = true
            //手势
            let tap = UITapGestureRecognizer(target: self, action: #selector(removeView))
            guideimageView.addGestureRecognizer(tap)
            
            Preferences.shared.mkChatFirst = false
        }
    }
    
    @objc fileprivate func removeView() {
        guideimageView.removeFromSuperview()
    }
}


fileprivate extension Reactive where Base: UIButton {
    
    var selectedSegmentIndex: UIBindingObserver<Base, Int> {
        return UIBindingObserver(UIElement: self.base) { button, index in
            if index == 0 {
                button.setImage(R.image.nav_member_nor(), for: .normal)
                button.setImage(R.image.nav_member_pre(), for: .highlighted)
            } else {
                button.setImage(R.image.nav_call_nor(), for: .normal)
                button.setImage(R.image.nav_call_pre(), for: .highlighted)
            }
        }
    }
    
}
