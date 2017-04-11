//
//  RxStore.swift
//  Move App
//
//  Created by jiang.duan on 2017/4/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift

class RxStore {
    
    static let shared = RxStore()
    
    // MARK: - State
    
    // MARK: - -Device-
    
    var deviceInfosState: Variable<[DeviceInfo]> = Variable([])
    var currentDeviceId: Variable<String?> = Variable(nil)
    
    // -- End State --
    
}
