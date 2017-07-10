//
//  WatchFriendsListViewModel.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/14.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class WatchFriendsListViewModel {
    
    var cellDatas: Driver<[DeviceFriend]>?
    
    let selected: Driver<DeviceFriend>
    
    var friends:[DeviceFriend]?
    
    init (input: (
        enterCount: Driver<Int>,
        selectedFriend: Driver<DeviceFriend>
        ),
          dependency: (
        deviceManager: DeviceManager,
        wireframe: Wireframe
        )
        ) {
        
        let deviceManager = dependency.deviceManager
        let _ = dependency.wireframe
        
        let enter = input.enterCount.filter({ $0 > 0 })
        
        self.selected = input.selectedFriend
        
        
        self.cellDatas = enter.flatMapLatest({ _ in
            return deviceManager.getWatchFriends(with: (deviceManager.currentDevice?.deviceId)!)
                .map{ deviceFriends in
                    let fs = deviceFriends.filter({$0.uid != UserInfo.shared.id})
                    self.friends = fs
                    return fs
                }
                .asDriver(onErrorJustReturn: [])
        })
    }
    
    
}





