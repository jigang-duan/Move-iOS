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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
