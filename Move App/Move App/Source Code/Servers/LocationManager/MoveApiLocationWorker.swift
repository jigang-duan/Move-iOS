//
//  MoveApiLocationWorker.swift
//  Move App
//
//  Created by lx on 17/3/9.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift

class MoveApiLocationWorker: MoveApiSafeZoneWorker, LocationWorkerProtocl {
    
    func getCurrentLocation(id: String) -> Observable<KidSate.LocationInfo>{
        return MoveApi.Location.getNew(deviceId: id).flatMapLatest(transformLocation)
    }
    
    func getHistoryLocation(id: String, start: Date, end: Date) -> Observable<[KidSate.LocationInfo]> {
        return MoveApi.Location.getHistory(deviceId: id, locationReq: MoveApi.LocationReq(start: start, end: end)).flatMap(transformHistoryLocation)
    }
    
    func fetchLocations(deviceIDs: [String]) -> Observable<[KidSate.LocationInfo]> {
        guard deviceIDs.count > 0 else {
            return Observable.just([])
        }
        
        let ids = deviceIDs.map{ MoveApi.LocationDeviceId(device_id: $0) }
        return MoveApi.Location.getMultiLocations(with: MoveApi.LocationMultiReq(locations: ids))
            .map { $0.locations }
            .filterNil()
            .map { $0.flatMap(transformLocationOfDevice) }
    }
    
    
    func fetchLbsLocation(lbs: KidSate.SOSLbsModel) -> Observable<KidSateSOS> {
        guard let deviceId = lbs.imei else {
            return Observable.just(KidSateSOS.empty())
        }
        
        let nearbts = lbs.bts?.map { MoveApi.Bts(bts: $0) }
        let nearwifi = lbs.wifi?.map({ MoveApi.Wifi(wifi: $0) })
        let info = MoveApi.LocationAdd(time: lbs.utc,
                            gps:  nil,
                            network: nil,
                            imei: deviceId,
                            smac: nil,
                            serverip: nil,
                            cdma: nil,
                            imsi: nil,
                            bts:  nearbts?.first,
                            nearbts: nearbts,
                            wifi: nearwifi?.first,
                            nearwifi: nearwifi,
                            fences: nil)
        
        let location = MoveApi.Location.getByLBS(deviceId: deviceId, locationAdd: info)
            .map{ $0.location }
            .filterNil()
            .map{ KidSate.LocationInfo(location: $0) }
        
        if let location = lbs.location {
            return Observable.just(KidSateSOS.gps(imei: deviceId, location: location))
        }
        
        if (nearbts == nil) && (nearwifi == nil) {
            return Observable.just(KidSateSOS.imei(deviceId))
        }
        
        if (nearbts != nil) && (nearwifi != nil) {
            return location.map { KidSateSOS.btsAndWifi(imei: deviceId, location: $0) }
        }
        
        if nearbts != nil {
            return location.map { KidSateSOS.bts(imei: deviceId, location: $0) }
        }
        
        return location.map { KidSateSOS.wifi(imei: deviceId, location: $0) }
    }
    
}

class MoveApiSafeZoneWorker: SafeZoneWorkerProtocl {
    
    func fetchSafeZone(deviceId: String) -> Observable<[KidSate.ElectronicFencea]> {
        return MoveApi.ElectronicFence.getFences(deviceId: deviceId).map({ transform(fences: $0.fences) })
    }
    
    func delectSafeZone(deviceId: String, fenceId: String) -> Observable<Bool> {
        return MoveApi.ElectronicFence.deleteFence(fenceId: fenceId)
            .map(errorTransform)
            .catchError(errorHandle)
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
        return MoveApi.ElectronicFence.settingFence(fenceId: fenceId, fenceReq: MoveApi.FenceReq(fence: fenceInfo))
            .map(errorTransform)
            .catchError(errorHandle)
    }
}


extension KidSate.LocationInfo {
    init(location: MoveApi.LocationInfo) {
        self.init()
        if let lat = location.lat, let lng = location.lng {
            self.location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
        self.address = location.addr
        self.accuracy = location.accuracy
        self.time = location.time
        self.type = KidSate.LocationType(rawValue: location.type ?? 0)
    }

}


fileprivate extension MoveApi.Wifi {
    init(wifi: KidSate.SOSLbsModel.WiFi) {
        self.init()
        self.mac = wifi.mac
        self.signal = wifi.signal
        self.ssid = wifi.ssid
    }
}

fileprivate extension MoveApi.Bts {
    init(bts: KidSate.SOSLbsModel.BTS) {
        self.init()
        self.mcc = bts.mcc
        self.mnc = bts.mnc
        self.lac =  bts.lac
        self.cellid = bts.cellId
        self.signal = bts.signal
    }
}


fileprivate func transform(fences: [MoveApi.FenceInfo]?) -> [KidSate.ElectronicFencea] {
    return fences?.map(transforma) ?? []
}

fileprivate func transforma(fence: MoveApi.FenceInfo) -> KidSate.ElectronicFencea {
    let locatio = KidSate.locatio(location: CLLocationCoordinate2D(latitude: fence.location?.lat ?? 0, longitude: fence.location?.lng ?? 0), address: fence.location?.addr)
    return KidSate.ElectronicFencea(ids: fence.id, name: fence.name, radius: fence.radius, active: fence.active, location: locatio)
}

fileprivate func transformLocationOfDevice(_ new: MoveApi.LocationOfDevice) -> KidSate.LocationInfo? {
    guard let location = new.location, let _ = location.lat, let _ = location.lng else {
        return nil
    }
    return  KidSate.LocationInfo(location: location)
}

fileprivate func transformLocation(_ new: MoveApi.LocationOfDevice) -> Observable<KidSate.LocationInfo> {
    guard let location = new.location, let _ = location.lat, let _ = location.lng else {
        return Observable.empty()
    }
    return  Observable.just(KidSate.LocationInfo(location: location))
}

fileprivate func transformHistoryLocation(_ history: MoveApi.LocationHistory) -> Observable<[KidSate.LocationInfo]> {
    guard let  locs = history.locations  else {
        return Observable.empty()
    }
    return  Observable.just(locs.flatMap(transform))
}

fileprivate func transform(_ location: MoveApi.LocationInfo) -> KidSate.LocationInfo? {
    guard let _ = location.lat, let _ = location.lng else {
        return nil
    }
    return KidSate.LocationInfo(location: location)
}
