//
//  TabsViewController.swift
//  Move App
//
//  Created by Jiang Duan on 17/1/20.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class TabsViewController: UITabBarController {
    
    var inlet = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewControllers = [
            R.storyboard.major.navHomeController()!,
            R.storyboard.main.choseDevice()!,
//            R.storyboard.main.instantiateInitialViewController()!,
            R.storyboard.social.instantiateInitialViewController()!
        ]
        
        self.selectedIndex = inlet
        if inlet == 1 {
            self.viewControllers?[0].tabBarItem.isEnabled = false
            self.viewControllers?[2].tabBarItem.isEnabled = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertServer.share.subscribe()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AlertServer.share.unsubscribe()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
