//
//  KidSate+SOSLbsModel.swift
//  Move App
//
//  Created by jiang.duan on 2017/7/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation

extension KidSate.SOSLbsModel {
    
    init?(aURL: URL) {
        guard
            let queryString = aURL.queryParameters,
            let imei = queryString["i"] else {
                return nil
        }
        self.init()
        self.imei = imei
        self.location =  KidSate.LocationInfo(ls: queryString["l"] ?? "")
        
        if let utcString = queryString["t"],
            let interval = TimeInterval(utcString) {
            self.utc = Date(timeIntervalSince1970: interval)
            self.location?.time = self.utc
        }
        if let btsString = queryString["c"] {
            self.bts = KidSate.SOSLbsModel.BTS.queryParameters(str: btsString)
        }
        if let wifiString = queryString["w"] {
            self.wifi = KidSate.SOSLbsModel.WiFi.queryParameters(str: wifiString)
        }
        
    }
    
    init?(url: URL) {
        guard
            let queryString = url.urlParameters,
            let imei = queryString["i"] as? String else {
                return nil
        }
        self.init()
        self.imei = imei
        self.location =  KidSate.LocationInfo(ls: (queryString["l"] as? String) ?? "")
        
        if let utcString = queryString["t"] as? String,
            let interval = TimeInterval(utcString) {
            self.utc = Date(timeIntervalSince1970: interval)
            self.location?.time = self.utc
        }
        
        self.bts = (queryString["c"] as? [String])?.flatMap({ KidSate.SOSLbsModel.BTS(cs: $0) })
        self.wifi = (queryString["w"] as? [String])?.flatMap({ KidSate.SOSLbsModel.WiFi(ws: $0) })
    }
    
}

fileprivate extension KidSate.LocationInfo {
    
    init?(ls: String) {
        let components = ls.components(separatedBy: ",")
        guard components.count >= 2 else {
            return nil
        }
        self.init()
        if
            let lat = CLLocationDegrees(components[0]),
            let lng = CLLocationDegrees(components[1]) {
            self.location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
    }
}

fileprivate extension KidSate.SOSLbsModel.BTS {
    init?(cs: String) {
        self.init(components: cs.components(separatedBy: ",").map({ Int($0) }))
    }
    
    init?(components: [Int?]) {
        guard components.count >= 5 else {
            return nil
        }
        
        self.init()
        self.mcc = components[0]
        self.mnc = components[1]
        self.lac = components[2]
        self.cellId = components[3]
        self.signal = components[4]
    }
    
    static func queryParameters(str: String) -> [KidSate.SOSLbsModel.BTS] {
        return str.components(separatedBy: "],[").map({  $0.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "") }).flatMap({ KidSate.SOSLbsModel.BTS(cs: $0) })
    }
}

fileprivate extension KidSate.SOSLbsModel.WiFi {
    init?(ws: String) {
        let components = ws.components(separatedBy: ",")
        guard components.count >= 3 else {
            return nil
        }
        self.init()
        self.mac = components[0]
        self.ssid = components[2]
        self.signal = Int(components[1])
    }
    
    static func queryParameters(str: String) -> [KidSate.SOSLbsModel.WiFi] {
        return str.components(separatedBy: "],[").map({  $0.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "") }).flatMap({ KidSate.SOSLbsModel.WiFi(ws: $0) })
    }
}
