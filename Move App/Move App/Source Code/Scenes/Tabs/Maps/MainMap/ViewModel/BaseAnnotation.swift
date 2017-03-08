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

class LocationAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var tag : Int = 0
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    init(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) {
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
    }
}
