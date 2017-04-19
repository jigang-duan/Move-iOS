//
//  MapUtility.swift
//  Move App
//
//  Created by jiang.duan on 2017/4/19.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation


class MapUtility {
    
    class func openPlacemark(name: String, location: CLLocationCoordinate2D) {
        let options = [ MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking ]
        let placemark = MKPlacemark(coordinate: location, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: options)
    }
}
