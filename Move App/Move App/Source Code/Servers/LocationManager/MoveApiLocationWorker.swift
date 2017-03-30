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
    
    func fetchSafeZone(deviceId: String) -> Observable<[KidSate.ElectronicFencea]>
    {
        return MoveApi.ElectronicFence.getFences(deviceId: deviceId).map({ self.transform(fences: $0.fences) })
    }
    
    func delectSafeZone(deviceId: String, fenceId: String) -> Observable<Bool> {
        return MoveApi.ElectronicFence.deleteFence(fenceId: fenceId).map{ $0.id == 0 }
    }

    func updateSafeZone(deviceId: String,  fence: KidSate.ElectronicFencea) -> Observable<Bool> {
        guard
            let fenceId = fence.ids,
            let lat = fence.location?.location?.latitude,
            let lng = fence.location?.location?.longitude else {
            return Observable.empty()
        }
        let fenceInfo = MoveApi.FenceInfo(id: fenceId,
                                          name: fence.name,
                                          location: MoveApi.Fencelocation(lat: lat, lng: lng),
                                          radius: fence.radius,
                                          active: fence.active)
        return MoveApi.ElectronicFence.settingFence(fenceId: fenceId, fenceReq: MoveApi.FenceReq(fence: fenceInfo)).map({ $0.id == 0 })
    }
    
    private func transform(fences: [MoveApi.FenceInfo]?) -> [KidSate.ElectronicFencea] {
        return fences?.map(transforma) ?? []
    }
    
    private func transforma(fence: MoveApi.FenceInfo) -> KidSate.ElectronicFencea {
        let locatio = KidSate.locatio(location: CLLocationCoordinate2D(latitude: fence.location?.lat ?? 0, longitude: fence.location?.lng ?? 0), address: fence.location?.addr)
        return KidSate.ElectronicFencea(ids: fence.id, name: fence.name, radius: fence.radius, active: fence.active, location: locatio)
    }
    
    private func transformLocation(_ new: MoveApi.LocationOfDevice) -> Observable<KidSate.LocationInfo> {
        guard let location = new.location, let lat = location.lat, let lng = location.lng else {
                return Observable.empty()
        }
        return  Observable.just(KidSate.LocationInfo(location: CLLocationCoordinate2DMake(lat, lng),
                                    address: location.addr,
                                    accuracy: location.accuracy,
                                    time: location.time))
    }
    
    private func transformHistoryLocation(_ history: MoveApi.LocationHistory) -> Observable<[KidSate.LocationInfo]> {
        guard let  locs = history.locations  else {
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
