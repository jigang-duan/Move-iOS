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
import CustomViews


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

extension MKMapView {
    
    func convertRect(radius: CLLocationDistance) -> CGRect {
        let region = MKCoordinateRegionMakeWithDistance(self.centerCoordinate, radius, radius)
        return self.convertRegion(region, toRectTo: self)
    }
}

extension MKMapView {
    
    var mainAnnotationView: PulsingAnnotationView? {
        guard let annotation = self.annotations.first else {
            return nil
        }
        return self.view(for: annotation) as? PulsingAnnotationView
    }
    
    func redrawRadius() {
        guard let annotation = self.annotations.first as? AccuracyAnnotation else {
            return
        }
        self.mainAnnotationView?.radius = convertRect(radius: annotation.accuracy).width
    }
}

extension Reactive where Base : MKMapView {
    
    var redrawRadius: UIBindingObserver<Base, Void> {
        return UIBindingObserver(UIElement: self.base) { mapView, _ in
            mapView.redrawRadius()
        }
    }
}
