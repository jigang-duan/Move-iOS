//
//  LocationManager.swift
//  Move App
//
//  Created by lx on 17/3/9.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift


protocol LocationWorkerProtocl: SafeZoneWorkerProtocl {
    func getCurrentLocation(id: String) -> Observable<KidSate.LocationInfo>
    func getHistoryLocation(id: String, start: Date, end: Date) -> Observable<[KidSate.LocationInfo]>
    
    func fetchLbsLocation(lbs: KidSate.SOSLbsModel) -> Observable<KidSateSOS>
    
    func fetchLocations(deviceIDs: [String]) -> Observable<[KidSate.LocationInfo]>
}

protocol SafeZoneWorkerProtocl {
    func fetchSafeZone(deviceId: String) -> Observable<[KidSate.ElectronicFence]>
    func delectSafeZone(deviceId: String, fenceId: String) -> Observable<Bool>
    func updateSafeZone(deviceId: String, fence: KidSate.ElectronicFence) -> Observable<Bool>
}

class LocationManager  {
    static let share = LocationManager()
    
    fileprivate var worker: LocationWorkerProtocl!
    
    init() {
        worker = MoveApiLocationWorker()
    }
    
    var currentLocation: Observable<KidSate.LocationInfo> {
        guard let deviceId = Me.shared.currDeviceID, deviceId.isNotEmpty else {
            return Observable<KidSate.LocationInfo>.empty()
        }
        return self.worker.getCurrentLocation(id: deviceId)
    }
    
    func location(deviceId: String) -> Observable<KidSate.LocationInfo> {
        return self.worker.getCurrentLocation(id: deviceId)
    }
    
    func locations(deviceIDs: [String]) -> Observable<[KidSate.LocationInfo]> {
        return self.worker.fetchLocations(deviceIDs: deviceIDs)
    }
    
    func getHistoryLocation(start: Date, end: Date) ->  Observable<[KidSate.LocationInfo]>{
        guard let deviceId = Me.shared.currDeviceID, deviceId.isNotEmpty else {
            return Observable<[KidSate.LocationInfo]>.empty()
        }
        return self.worker.getHistoryLocation(id: deviceId, start: start, end: end)
    }
    
    func fetchSafeZone() -> Observable<[KidSate.ElectronicFence]> {
        guard let deviceId = Me.shared.currDeviceID, deviceId.isNotEmpty else {
            return Observable.empty()
        }
        return self.worker.fetchSafeZone(deviceId: deviceId).catchErrorEmpty()
    }
    
    func delectSafeZone(_ fenceId: String) -> Observable<Bool>{
        guard let deviceId = Me.shared.currDeviceID, deviceId.isNotEmpty else {
            return Observable<Bool>.empty()
        }
        return self.worker.delectSafeZone(deviceId: deviceId, fenceId: fenceId)
    }
    
    func updateSafeZone(_ fence: KidSate.ElectronicFence) -> Observable<Bool> {
        guard let deviceId = Me.shared.currDeviceID, deviceId.isNotEmpty else {
            return Observable<Bool>.empty()
        }
        return self.worker.updateSafeZone(deviceId: deviceId, fence: fence)
    }
 
    func fetch(lbs: KidSate.SOSLbsModel) -> Observable<KidSateSOS>  {
        return self.worker.fetchLbsLocation(lbs: lbs)
    }
}


struct KidSateSOS {
    var type: KidSateSOSType
    var imei: String?
    var location: KidSate.LocationInfo?
    var deviceInof: DeviceInfo?
}

enum KidSateSOSType {
    case empty
    case imei
    case gps
    case bts
    case wifi
    case btsAndWifi
}

extension KidSateSOS {
    
    static func empty() -> KidSateSOS {
        return KidSateSOS(type: .empty, imei: nil, location: nil, deviceInof: nil)
    }
    
    static func imei(_ id: String) -> KidSateSOS {
        return KidSateSOS(type: .imei, imei: id, location: nil, deviceInof: nil)
    }
    
    static func gps(imei: String, location: KidSate.LocationInfo) -> KidSateSOS {
        return KidSateSOS(type: .gps, imei: imei, location: location, deviceInof: nil)
    }
    
    static func bts(imei: String, location: KidSate.LocationInfo) -> KidSateSOS {
        return KidSateSOS(type: .bts, imei: imei, location: location, deviceInof: nil)
    }
    
    static func wifi(imei: String, location: KidSate.LocationInfo) -> KidSateSOS {
        return KidSateSOS(type: .wifi, imei: imei, location: location, deviceInof: nil)
    }
    
    static func btsAndWifi(imei: String, location: KidSate.LocationInfo) -> KidSateSOS {
        return KidSateSOS(type: .btsAndWifi, imei: imei, location: location, deviceInof: nil)
    }
    
    func clone(deviceInof: DeviceInfo) -> KidSateSOS {
        return KidSateSOS(type: self.type, imei: self.imei, location: self.location, deviceInof: deviceInof)
    }
    
}

