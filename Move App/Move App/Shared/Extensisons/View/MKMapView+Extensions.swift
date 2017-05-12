//
//  MKMapView+Extensions.swift
//  Move App
//
//  Created by jiang.duan on 2017/5/12.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa


extension Reactive where Base : MKMapView {
    
    var region: UIBindingObserver<Base, MKCoordinateRegion> {
        return UIBindingObserver(UIElement: self.base) { mapView, region in
            mapView.setRegion(region, animated: true)
        }
    }
    
    var soleAnnotion: UIBindingObserver<Base, MKAnnotation> {
        return UIBindingObserver(UIElement: self.base) { mapView, annotion in
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(annotion)
        }
    }
    
    var soleAccuracyAnnotation: UIBindingObserver<Base, AccuracyAnnotation> {
        return UIBindingObserver(UIElement: self.base) { mapView, annotion in
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(annotion)
        }
    }
    
}

func convert(_ mapView: MKMapView, radius: CLLocationDistance) -> CGRect {
    let region = MKCoordinateRegionMakeWithDistance(mapView.centerCoordinate, radius, radius)
    return mapView.convertRegion(region, toRectTo: mapView)
}
