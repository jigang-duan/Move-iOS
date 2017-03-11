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
            deviceManager.getDeviceList().map{ deviceInfos in
                self.setDevice(deviceInfos: deviceInfos)
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
    
    
    func setDevice(deviceInfos: [MoveApi.DeviceInfo]?){
        self.devices = deviceInfos?.map({ (element) -> DeviceInfo in
            var info = DeviceInfo()
            info.deviceId = element.deviceId
            info.pid = element.pid
            info.property = DeviceProperty(active: element.property?.active, bluetooth_address: element.property?.bluetooth_address, device_model: element.property?.device_model, firmware_version: element.property?.firmware_version, ip_address: element.property?.ip_address, kernel_version: element.property?.kernel_version, mac_address: element.property?.mac_address, phone_number: element.property?.phone_number, languages: element.property?.languages, power: element.property?.power)
            info.user = DeviceUser(uid: element.user?.uid, number: element.user?.number, nickname: element.user?.nickname, profile: element.user?.profile, gender: element.user?.gender, height: element.user?.height, weight: element.user?.weight, birthday: element.user?.birthday)
            return info
        })
    }
}





