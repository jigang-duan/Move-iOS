//
//  MoveApi+ElectronicFence+Mappable.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/2/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import ObjectMapper


extension MoveApi {
    
    struct FenceList {
        var fences: [FenceInfo]?
    }
    
    struct FenceInfo {
        var name: String?
        var location: Fencelocation?
        var radius: Float64?
        var active: Bool?
    }

    struct Fencelocation {
        var lat: Float64?
        var lng: Float64?
        var addr: String?
    }
}

extension MoveApi.FenceList: Mappable {
    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        fences <- map["fences"]
    }
}

extension MoveApi.FenceInfo: Mappable {
    init?(map: Map) {
    }
    
    init(name: String, location: MoveApi.Fencelocation, radius: Float64) {
        self.name = name
        self.location = location
        self.radius = radius
    }
    
    mutating func mapping(map: Map) {
        name <- map["name"]
        location <- map["location"]
        radius <- map["radius"]
        active <- map["active"]
    }
}

extension MoveApi.Fencelocation: Mappable {
    init?(map: Map) {
    }
    
    init(lat: Float64, lng: Float64) {
        self.lat = lat
        self.lng = lng
    }
    
    mutating func mapping(map: Map) {
        lat <- map["lat"]
        lng <- map["lng"]
        addr <- map["addr"]
    }
}



