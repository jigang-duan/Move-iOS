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
    
    let enterSubject = BehaviorSubject<Bool>(value: false)
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewControllers = [
            R.storyboard.major.navHomeController()!,
            R.storyboard.main.choseDevice()!
            //R.storyboard.social.instantiateInitialViewController()!
        ]
        
        let hasDevice = RxStore.shared.deviceInfosState.asObservable()
            .map({ $0.count > 0 })
        
        
        hasDevice.bindNext({[weak self] in
                self?.viewControllers?[0].tabBarItem.isEnabled = $0
            })
            .addDisposableTo(bag)
        
        enterSubject.asObservable()
            .filter({$0})
            .withLatestFrom(hasDevice)
            .filter({ !$0 })
            .bindNext({ [weak self] _ in
                self?.selectedIndex = 1
            })
            .addDisposableTo(bag)
        
        MessageServer.share.syncDataInitalization(disposeBag: bag)
        MessageServer.share.subscribe().addDisposableTo(bag)
        AlertServer.share.subscribe().addDisposableTo(bag) 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enterSubject.onNext(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
