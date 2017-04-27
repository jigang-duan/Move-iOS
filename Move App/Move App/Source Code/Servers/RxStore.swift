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
    
    var userId: Variable<String?> = Variable(nil)
    
    // MARK: - -Device-
    
    var deviceInfosState: Variable<[DeviceInfo]> = Variable([])
    var currentDeviceId: Variable<String?> = Variable(nil)
    
    // -- End State --
    
}

extension RxStore {
    
    var uidObservable: Observable<String> {
        return userId.asObservable().filterNil()
    }
    
    // MARK: - -Device-
    
    var deviceInfosObservable: Observable<[DeviceInfo]> {
        return deviceInfosState.asObservable().filterEmpty()
    }
    
    var deviceIdObservable: Observable<String> {
        return currentDeviceId.asObservable().filterNil().distinctUntilChanged()
    }
    
    var currentDevice: Observable<DeviceInfo> {
        return deviceInfosObservable
            .withLatestFrom(deviceIdObservable) { (s, id) in s.filter{ $0.deviceId == id }.first }
            .filterNil()
    }
    
    func device(form id: String) -> Observable<DeviceInfo> {
        return deviceInfosObservable.map{ $0.filter{ $0.deviceId == id }.first }.filterNil()
    }
    
    func bind(property: DeviceProperty) {
        guard let currentId = currentDeviceId.value else {
            return
        }
        
        var states = deviceInfosState.value
        guard states.count > 0 else {
            return
        }
        
        if let index = states.index(where: { $0.deviceId == currentId }) {
            if let old = states[index].property, old == property {
                return
            }
            states[index].property = property
            deviceInfosState.value = states
        }
    }
}
