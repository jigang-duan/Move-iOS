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
    let sections: Driver<[SectionOfCellData]>
    
    // }
    
    init (input: (Observable<Int>),
        dependency: (
        userManager: UserManager,
        validation: DefaultValidation,
        wireframe: Wireframe
        )
        ) {
        
        let userManger = dependency.userManager
        let _ = dependency.validation
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
        
        let deviceInfo = MokDevices()
        self.sections = enter.flatMapLatest({ _ in
            deviceInfo.getDeviceList()
        }).asDriver(onErrorJustReturn: [])
        
    }
}
