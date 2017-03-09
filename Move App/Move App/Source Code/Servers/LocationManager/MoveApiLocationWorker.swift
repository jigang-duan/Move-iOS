//
//  MoveApiLocationWorker.swift
//  Move App
//
//  Created by lx on 17/3/9.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift

class MoveApiLocationWorker: LocationWorkerProtocl {
    
    func getCurrentLocation(id: String) -> Observable<KidSate.LocationInfo>{
            return MoveApi.Location.getNew(deviceId: id).flatMapLatest(transformLocation)
    }
    
    func getHistoryLocation(id: String, start: Date, end: Date) -> Observable<[KidSate.LocationInfo]> {
            return MoveApi.Location.getHistory(deviceId: id, locationReq: MoveApi.LocationReq(start: start, end: end)).flatMap(transformHistoryLocation)
    }
    
    private func transformLocation(_ new: MoveApi.LocationNew) -> Observable<KidSate.LocationInfo> {
        guard let location = new.location, let lat = location.lat, let lng = location.lng else {
                return Observable.empty()
        }
        return  Observable.just(KidSate.LocationInfo(location: CLLocationCoordinate2DMake(lat, lng),
                                    address: location.addr,
                                    accuracy: location.accuracy,
                                    time: location.time))
    }
    
    private func transformHistoryLocation(_ history: MoveApi.LocationHistory) -> Observable<[KidSate.LocationInfo]> {
        guard let  locs = history.locations , locs.count > 0 else {
            return Observable.empty()
        }
        return  Observable.just(locs.flatMap(transform))
    }
    
    private func transform(_ location: MoveApi.LocationInfo) -> KidSate.LocationInfo? {
        guard let lat = location.lat, let lng = location.lng else {
            return nil
        }
        return KidSate.LocationInfo(location: CLLocationCoordinate2DMake(lat, lng),
                             address: location.addr,
                             accuracy: location.accuracy,
                             time: location.time)
    }
}
