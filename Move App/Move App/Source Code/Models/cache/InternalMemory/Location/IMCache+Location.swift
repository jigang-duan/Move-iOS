//
//  IMCache+Location.swift
//  Move App
//
//  Created by jiang.duan on 2017/5/15.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift

class IMCacheLocationWorker: IMCacheSafeZoneWorker {
}

class IMCacheSafeZoneWorker: SafeZoneWorkerProtocl {
    
    func fetchSafeZone(deviceId: String) -> Observable<[KidSate.ElectronicFencea]> {
        guard let fenceas = safeZones[deviceId] else {
            return Observable.empty()
        }
        return Observable.just(fenceas)
    }
    
    func delectSafeZone(deviceId: String, fenceId: String) -> Observable<Bool> {
        return Observable.empty()
    }
    
    func updateSafeZone(deviceId: String,  fence: KidSate.ElectronicFencea) -> Observable<Bool> {
        return Observable.empty()
    }
}

extension ObservableType where E == SafeZones {
    func catchingSafeZones(device id: String) -> Observable<SafeZones> {
        return flatMap { element -> Observable<SafeZones> in
            safeZones[id] = element
            return Observable.just(element)
        }
    }
}

typealias SafeZone = KidSate.ElectronicFencea
typealias SafeZones = [SafeZone]
typealias MapSafeZones = [String : SafeZones]

fileprivate var safeZones: MapSafeZones = [:]
