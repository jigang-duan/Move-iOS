//
//  AccountViewModel.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/8.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AccountViewModel {
    // outputs {
    
    let sections: Observable<[SectionOfCellData]>
    
    // }
    
    init(input: (Observable<Int>),
         dependency: (
            userManager: UserManager,
            deviceInfo: MokDevices
        )
        ) {
        
        let devsinfo = dependency.deviceInfo.getDeviceTerse()
            .map { (devs) -> [SectionOfCellData.Item] in
                let items: [SectionOfCellData.Item] = devs
                return items + [AddDeviceCellData()]
            }.map {
                [SectionOfCellData(header: R.string.localizable.id_section_header_device(),
                                  items: $0)]
        }
        
        let userinof = dependency.userManager.getProfile()
            .map(AccountViewModel.transferUserProfile)
            .toArray()
        
        sections = input
            .filter {$0 > 0}
            .flatMapLatest { _ in
                //Observable.combineLatest(userinof, devsinfo) { $0 + $1 }
                devsinfo
        }.shareReplay(1)
            .observeOn(MainScheduler.instance)
    }
    
    private class func transferUserProfile(_ profile: UserInfo.Profile) -> SectionOfCellData {
        return SectionOfCellData(header: R.string.localizable.id_nil(),
                          items: [UserCellData(iconUrl: profile.iconUrl,
                                         account: profile.username ?? "",
                                         describe: profile.nickname ?? "")
            ])
    }
}

class MokDevices {
    
    let devcells = [DeviceCellData(devType: "Family watch 2", name: "Angela", iconUrl: nil)]
    
    func getDeviceTerse() -> Observable<[DeviceCellData]> {
        return Observable.just(devcells)
    }
    
    func getDeviceList() -> Observable<[SectionOfCellData]> {
        return Observable.just([SectionOfCellData(header: "Devices", items: devcells)])
    }
}
