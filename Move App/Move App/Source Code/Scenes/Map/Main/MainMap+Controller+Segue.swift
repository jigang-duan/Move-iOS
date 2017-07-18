//
//  MainMap+Controller+Segue.swift
//  Move App
//
//  Created by jiang.duan on 2017/7/11.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation

// Skip
extension MainMapController {
    
    func propelToTargetController() {
        if let target = Distribution.shared.target {
            switch target {
            case .chatMessage(let index):
                showChat(index: index)
                Distribution.shared.target = nil
            default: ()
            }
        }
    }
}

// Segue
extension MainMapController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = R.segue.mainMapController.locationHistory(segue: segue)?.destination {
            if let device = DeviceManager.shared.currentDevice {
                vc.Sprofile = device.user?.profile
                vc.Snikename = device.user?.nickname
                vc.deviceId = device.deviceId
            }
        }
    }
    
    func showChat(index: Int = 0) {
        if let chatController = R.storyboard.social.chat() {
            chatController.selectedIndexVariable.value = index
            self.navigationController?.show(chatController, sender: nil)
        }
    }
    
    func showAllKidsLocationController() {
        self.performSegue(withIdentifier: R.segue.mainMapController.showAllKidsLocation, sender: nil)
    }
}
