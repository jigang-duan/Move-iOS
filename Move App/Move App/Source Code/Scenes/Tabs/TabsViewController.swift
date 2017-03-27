//
//  TabsViewController.swift
//  Move App
//
//  Created by Jiang Duan on 17/1/20.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import RxSwift
import RxCocoa

class TabsViewController: UITabBarController {
    
    var inlet = 0
    
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewControllers = [
            R.storyboard.major.navHomeController()!,
            R.storyboard.main.choseDevice()!
            //R.storyboard.social.instantiateInitialViewController()!
        ]
        
        self.selectedIndex = inlet
        if inlet == 1 {
            self.viewControllers?[0].tabBarItem.isEnabled = false
            self.viewControllers?[2].tabBarItem.isEnabled = false
        }
        
        MessageServer.share.syncDataInitalization(disposeBag: bag)
        MessageServer.share.subscribe().addDisposableTo(bag)
        AlertServer.share.subscribe().addDisposableTo(bag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
