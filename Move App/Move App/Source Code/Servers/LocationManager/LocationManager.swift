//
//  LocationManager.swift
//  Move App
//
//  Created by lx on 17/3/9.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift


protocol LocationWorkerProtocl {
    func getCurrentLocation(id: String) -> Observable<KidSate.LocationInfo>
    func getHistoryLocation(id: String, start: Date, end: Date) -> Observable<[KidSate.LocationInfo]>
}

class LocationManager  {
    static let share = LocationManager()
    
    fileprivate var worker: LocationWorkerProtocl!
    
    init() {
        worker = MoveApiLocationWorker()
    }
    
    func getCurrentLocation() ->  Observable<KidSate.LocationInfo>{
        guard let deviceId = Me.shared.currDeviceID else {
            return Observable<KidSate.LocationInfo>.empty()
        }
        return self.worker.getCurrentLocation(id: deviceId)
    }
    
    func getHistoryLocation(start: Date, end: Date) ->  Observable<[KidSate.LocationInfo]>{
        guard let deviceId = Me.shared.currDeviceID else {
            return Observable<[KidSate.LocationInfo]>.empty()
        }
        return self.worker.getHistoryLocation(id: deviceId, start: start, end: start)
    }
}
