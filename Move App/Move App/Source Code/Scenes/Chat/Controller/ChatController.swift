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
    
    func chatAction(enable: Bool) {
        if enable{
            chatIconBtn.setImage(UIImage(named: "nav_member_nor"), for: .normal)
            chatIconBtn.setImage(UIImage(named: "nav_member_pre"), for: .highlighted)
            chatIconBtn.tag = 10
        }else
        {
            chatIconBtn.setImage(UIImage(named: "nav_call_nor"), for: .normal)
            chatIconBtn.setImage(UIImage(named: "nav_call_pre"), for: .highlighted)
            chatIconBtn.tag = 11
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.guideView()
        
        segmentedOutlet.setTitle(DeviceManager.shared.currentDevice?.user?.nickname, forSegmentAt: 1)
        
        segmentedOutlet.rx.selectedSegmentIndex
            .asDriver()
            .map({ $0 != 0 })
            .drive(familyChatView.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        segmentedOutlet.rx.selectedSegmentIndex
            .asDriver()
            .map({ $0 == 0 })
            .drive(onNext:chatAction)
            .addDisposableTo(disposeBag)
      

        segmentedOutlet.rx.selectedSegmentIndex
            .asDriver()
            .map({ $0 != 1 })
            .drive(singleChatView.rx.isHidden)
            .addDisposableTo(disposeBag)
    }
    

    
    func guideView() {
        
        if UserDefaults.standard.value(forKey: "isFirst") == nil {
            //引导
            guideimageView = UIImageView(image: UIImage(named: "Message_friendsuser_guide"))
            guideimageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            let window = UIApplication.shared.windows[0]
            window.addSubview(guideimageView)
            guideimageView.isUserInteractionEnabled = true
            //手势
            let tap = UITapGestureRecognizer(target: self, action: #selector(ChatController.removeView))
            guideimageView.addGestureRecognizer(tap)
            
            UserDefaults.standard.set(false, forKey: "isFirst")
        }
    }
    
    func removeView() {
        guideimageView.removeFromSuperview()
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
