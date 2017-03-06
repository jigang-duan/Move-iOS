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
    let cellDatas: Observable<[DeviceCellData]>
    
    // }
    
    init (input: (Observable<Int>),
        dependency: (
        userManager: UserManager,
        deviceManager: DeviceManager,
        wireframe: Wireframe
        )
        ) {
        
        let userManger = dependency.userManager
        let deviceManager = dependency.deviceManager
        let _ = dependency.wireframe
        
        let enter = input.filter({ $0 > 0 })
        
        self.accountName = enter.flatMapLatest { _ in
            userManger.getProfile()
                .map{ $0.username ?? "" }
        }.asDriver(onErrorJustReturn: "")
        
        self.head = enter.flatMapLatest({ _ in
            userManger.getProfile()
                .map({ $0.iconUrl ?? "" })
        }).asDriver(onErrorJustReturn: "")
        
     
        self.cellDatas = enter.flatMapLatest({ _ in
            deviceManager.getDeviceList().map{ deviceInfos in
                var cellDatas: [DeviceCellData] = []
                for info in deviceInfos {
//                    MARK: for test
                    let cellData = DeviceCellData(devType: info.property?.device_model ?? "kid watch", name: info.user?.nickname, iconUrl: info.user?.profile ?? "")
                    cellDatas.append(cellData)
                }
                return cellDatas
            }
        })
        
    }
}





