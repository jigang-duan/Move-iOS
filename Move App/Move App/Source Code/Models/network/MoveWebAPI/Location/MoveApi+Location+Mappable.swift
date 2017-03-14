//
//  MoveApi+Location+Mappable.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/2/13.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import ObjectMapper


extension MoveApi {
    
    struct LocationAdd {
        var time: Date?
        var gps: Gps?
        var network: String?
        var imei: String?
        var smac: String?
        var serverip: String?
        var cdma: Bool?
        var imsi: String?
        var bts: Bts?
        var nearbts: [Bts]?
        var wifi: Wifi?
        var nearwifi: [Wifi]?
    }
    
    struct Gps {
        var lat: Double?
        var lng: Double?
        var sat: Int?
    }
    
    struct Bts {
        var mcc: Int?
        var mnc: Int?
        var lac: Int?
        var cellid: Int?
        var signal: Int?
    }
    
    struct Wifi {
        var mac: String?
        var signal: Int?
        var ssid: String?
    }
    
    struct LocationReq {
        var start: Date?
        var end: Date?
    }
    
    struct LocationOfDevice {
        var device_id: String?
        var location: LocationInfo?
    }
    
    struct LocationHistory {
        var device_id: String?
        var locations: [LocationInfo]?
    }
    
    struct LocationMultiReq {
        var locations: [LocationDeviceId]?
    }
    
    struct LocationDeviceId {
        var device_id: String?
    }
    
    struct Locations {
        var locations: [LocationOfDevice]?
    }
    
    struct  LocationInfo {
        var lat: Double?
        var lng: Double?
        var addr: String?
        var accuracy: Double?
        var time: Date?
    }
}

extension MoveApi.LocationAdd: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        time <- (map["time"], DateIntTransform())
        gps <- map["gps"]
        network <- map["network"]
        imei <- map["imei"]
        smac <- map["smac"]
        serverip <- map["serverip"]
        cdma <- map["cdma"]
        imsi <- map["imsi"]
        bts <- map["bts"]
        nearbts <- map["nearbts"]
        wifi <- map["wifi"]
        nearwifi <- map["nearwifi"]
    }
}

extension MoveApi.Gps: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        lat <- map["lat"]
        lng <- map["lng"]
        sat <- map["sat"]
    }
}

extension MoveApi.Bts: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        mcc <- map["mcc"]
        mnc <- map["mnc"]
        lac <- map["lac"]
        cellid <- map["cellid"]
        signal <- map["signal"]
    }
}

extension MoveApi.Wifi: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        mac <- map["mac"]
        signal <- map["signal"]
        ssid <- map["ssid"]
    }
}

extension MoveApi.LocationReq: Mappable{
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        start <- (map["start"], DateIntTransform())
        end <- (map["end"], DateIntTransform())
    }
}

extension MoveApi.LocationOfDevice: Mappable{
    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        device_id <- map["device_id"]
        location <- map["location"]
    }
}

extension MoveApi.LocationHistory: Mappable{
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        device_id <- map["device_id"]
        locations <- map["locations"]
    }
}

extension MoveApi.LocationMultiReq: Mappable{
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        locations <- map["locations"]
    }
}

extension MoveApi.LocationDeviceId: Mappable{
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        device_id <- map["device_id"]
    }
}

extension MoveApi.Locations: Mappable{
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        locations <- map["locations"]
    }
}

extension MoveApi.LocationInfo: Mappable{
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        lat <- map["lat"]
        lng <- map["lng"]
        addr <- map["addr"]
        accuracy <- map["accuracy"]
        time <- (map["time"], DateIntTransform())
    }
}

