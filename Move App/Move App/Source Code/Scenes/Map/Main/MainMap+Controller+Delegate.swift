//
//  MainMap+Controller+Delegate.swift
//  Move App
//
//  Created by jiang.duan on 2017/7/11.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import MapKit
import MessageUI
import CustomViews

extension MainMapController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? AccuracyAnnotation {
            let identifier = "mainMapAccuracyAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? PulsingAnnotationView
            if annotationView == nil {
                annotationView = PulsingAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.radius = mapView.convertRect(radius: annotation.accuracy).width
            }
            annotationView?.canShowCallout = false
            return annotationView
        }
        return nil
    }
    
    func dotDot(online: Bool) {
        self.mapView.mainAnnotationView?.dotColorDot = online ? defaultDotColor : .gray
    }
}


extension MainMapController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
        switch result{
        case .sent:
            Logger.debug("短信已发送")
        case .cancelled:
            Logger.debug("短信取消发送")
        case .failed:
            Logger.debug("短信发送失败")
        }
    }
}
