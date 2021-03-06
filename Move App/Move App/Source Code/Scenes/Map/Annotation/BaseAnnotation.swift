//
//  BaseAnnotation.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import MapKit

class BaseAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    init(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) {
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
    }
}

class AccuracyAnnotation: BaseAnnotation {
    var accuracy: CLLocationDistance = 0.0
    
    init(_ coordinate: CLLocationCoordinate2D, accuracy: CLLocationDistance) {
        super.init(coordinate)
        self.accuracy = accuracy
    }
    
    init(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees, accuracy: CLLocationDistance) {
        super.init(latitude, longitude)
        self.accuracy = accuracy
    }
}

func ==(lhs: AccuracyAnnotation, rhs: AccuracyAnnotation) -> Bool {
    return lhs.coordinate.latitude == rhs.coordinate.latitude
        && lhs.coordinate.longitude == rhs.coordinate.longitude
        && lhs.accuracy == rhs.accuracy
}

class LocationAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    init(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) {
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
    }
}

class TagAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var tag: Int = -1
    var info: KidSate.LocationInfo?
    var name : String?
    var device_id : String?
    var profile : String?
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    init(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) {
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
    }
}


class TargetAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    var selected: Bool = false
    var targetId: String?
    
    var name: String?
    var address: String?
    var url: String?
    
    init(_ coordinate: CLLocationCoordinate2D,
         name: String? = nil,
         address: String? = nil,
         url: String? = nil) {
        self.coordinate = coordinate
        self.name = name
        self.address = address
        self.url = url
    }
    
    init(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) {
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    init(other: TargetAnnotation) {
        self.coordinate = other.coordinate
        self.name = other.name
        self.address = other.address
        self.url = other.url
        self.selected = other.selected
        self.targetId = other.targetId
    }
}

func ==(lhs: TargetAnnotation, rhs: TargetAnnotation) -> Bool {
    return lhs.coordinate.latitude == rhs.coordinate.latitude
        && lhs.coordinate.longitude == rhs.coordinate.longitude
        && lhs.name == rhs.name
        && lhs.address == rhs.address
        && lhs.url == rhs.url
        && lhs.targetId == rhs.targetId
}

extension TargetAnnotation {

    func clone(selected: Bool) -> TargetAnnotation {
        let targetAnnotation = TargetAnnotation(other: self)
        targetAnnotation.selected = selected
        return targetAnnotation
    }
}
