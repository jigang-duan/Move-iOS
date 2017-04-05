//
//  AccountAndChoseDeviceViewModel.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/21.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AccountAndChoseDeviceViewModel {
    // outputs {
    
    let head: Driver<String>
    let accountName: Driver<String>
    var cellDatas: Observable<[DeviceCellData]>?
    
    let selected: Driver<Void>
    
    var devices: [DeviceInfo]?
    
    init (input: (
        enterCount: Observable<Int>,
        selectedDeviceInfo: Observable<DeviceInfo>
        ),
        dependency: (
        userManager: UserManager,
        deviceManager: DeviceManager,
        wireframe: Wireframe
        )
        ) {
        
        let userManger = dependency.userManager
        let deviceManager = dependency.deviceManager
        let _ = dependency.wireframe
        
        let enter = input.enterCount.filter({ $0 > 0 })
        
        self.accountName = enter.flatMapLatest { _ in
            userManger.getProfile()
                .map{ $0.nickname ?? "" }
        }.asDriver(onErrorJustReturn: "")
        
        self.head = enter.flatMapLatest({ _ in
            userManger.getProfile()
                .map({ $0.iconUrl ?? "" })
        }).asDriver(onErrorJustReturn: "")
        
        self.selected = input.selectedDeviceInfo
            .flatMapLatest(deviceManager.setCurrentDevice)
            .map({ _ in Void() })
            .asDriver(onErrorJustReturn: ())
        
     
        self.cellDatas = enter.flatMapLatest({ _ in
            deviceManager.fetchDevices().map{ [weak self] deviceInfos in
                self?.devices = deviceInfos
                var cellDatas: [DeviceCellData] = []
                for info in deviceInfos {
                    var deviceType = ""
                    var icon = ""
                    switch info.pid! {
                    case 0x101:
                        deviceType = "MB12"
                        icon = "device_ic_mb12"
                    case 0x201:
                        deviceType = "Kids Watch 2"
                        icon = "device_ic_kids"
                    default:
                        deviceType = "Other"
                        icon = "device_ic_mb22"
                    }
                    let cellData = DeviceCellData(devType: deviceType, name: info.user?.nickname, iconUrl: icon)
                    cellDatas.append(cellData)
                }
                return cellDatas
            }
        })
        
    }
    
}





