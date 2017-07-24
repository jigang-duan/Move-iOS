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
    @IBOutlet weak var page0LeadConstraint: NSLayoutConstraint!
    
    var disposeBag = DisposeBag()
    
    var guideimageView: UIImageView!
    
    @IBOutlet weak var chatIconBtn: UIButton!
    
    var selectedIndexVariable = Variable(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        segmentedOutlet.setTitle(R.string.localizable.id_family_chat(), forSegmentAt: 0)
        segmentedOutlet.setTitle(DeviceManager.shared.currentDevice?.user?.nickname, forSegmentAt: 1)
        
        (segmentedOutlet.rx.value <-> selectedIndexVariable).addDisposableTo(disposeBag)
        
        selectedIndexVariable.asDriver()
            .map{ $0 != 0 }
            .drive(familyChatView.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        selectedIndexVariable.asDriver()
            .map{ $0 != 1 }
            .drive(singleChatView.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        let viewWidth = self.view.bounds.width
        selectedIndexVariable.asObservable()
            .map{ -viewWidth * CGFloat($0) }
            .bindTo(page0LeadConstraint.rx.constant)
            .addDisposableTo(disposeBag)
        
        selectedIndexVariable.asDriver()
            .drive(chatIconBtn.rx.selectedSegmentIndex)
            .addDisposableTo(disposeBag)
        
        chatIconBtn.rx.tap.asDriver()
            .withLatestFrom(selectedIndexVariable.asDriver())
            .filter { $0 == 1 }
            .withLatestFrom(RxStore.shared.currentDeviceId.asDriver())
            .filterNil()
            .withLatestFrom(RxStore.shared.deviceInfosState.asDriver()) { (id, infos) in infos.filter { id == $0.deviceId }.first }
            .filterNil()
            .map{ URL(deviceInfo: $0) }
            .filterNil()
            .drive(onNext: { DefaultWireframe.sharedInstance.open(url: $0) })
            .addDisposableTo(disposeBag)
        
        chatIconBtn.rx.tap.asDriver()
            .withLatestFrom(selectedIndexVariable.asDriver())
            .filter { $0 == 0 }
            .drive(onNext: { [weak self] (_) in
                self?.performSegue(withIdentifier: R.segue.chatController.showFamilyMembers, sender: nil)
            })
            .addDisposableTo(disposeBag)
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ChatController {
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let familyChat = R.segue.chatController.showFamilyChat(segue: segue)?.destination {
            familyChat.isFamilyChat = true
            selectedIndexVariable.asObservable().map{ $0 == 0 }.bindTo(familyChat.selectedSubject).addDisposableTo(disposeBag)
            familyChat.hasUnReadSubject.asObservable().map{!$0}.bindTo(segmentedOutlet.rx.isLeftBadgeHidden).addDisposableTo(disposeBag)
        }
        if let singleChat = R.segue.chatController.showSingleChat(segue: segue)?.destination {
            singleChat.isFamilyChat = false
            selectedIndexVariable.asObservable().map{ $0 == 1 }.bindTo(singleChat.selectedSubject).addDisposableTo(disposeBag)
            singleChat.hasUnReadSubject.asObservable().map{!$0}.bindTo(segmentedOutlet.rx.isRightBadgeHidden).addDisposableTo(disposeBag)
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

