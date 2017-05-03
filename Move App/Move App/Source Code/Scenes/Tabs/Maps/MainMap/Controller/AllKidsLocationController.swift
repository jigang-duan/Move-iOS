//
//  AllKidsLocationController.swift
//  Move App
//
//  Created by lx on 17/3/9.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa

class AllKidsLocationController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var addressOutlet: UILabel!
    @IBOutlet weak var navOutlet: UIButton!
    @IBOutlet weak var barItemOutlet: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        let locations = RxStore.shared.deviceInfosObservable
            .map { (devices) in devices.flatMap { $0.deviceId } }
            .flatMapLatest { LocationManager.share.locations(deviceIDs: $0) }
        
        let fetchAnnotations = Observable.combineLatest(RxStore.shared.deviceIdObservable, RxStore.shared.deviceInfosObservable, locations, resultSelector: transform)
        
        let tap = barItemOutlet.rx.tap.asObservable()
            .withLatestFrom(fetchAnnotations)
        
        let annotations = Observable.merge(fetchAnnotations, tap)
            .filterEmpty()
            .share()
        
        annotations
            .map{ calculateCentreDistance($0) }
            .bindNext({ [unowned self] in
                let region = MKCoordinateRegionMakeWithDistance($0.0, $0.1, $0.1)
                self.mapView.setRegion(region, animated: true)
            })
            .addDisposableTo(disposeBag)
        
        annotations
            .bindNext { [unowned self] in
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations($0)
            }
            .addDisposableTo(disposeBag)
        
        let selected = annotations
            .map { (anns) in anns.filter{ $0.selected }.first }
            .filterNil()
        
        let didSelect = mapView.rx.didSelectAnnotationView.asObservable()
            .map { $0.annotation as? TargetAnnotation }
            .filterNil()
            .share()
            
        didSelect
            .bindNext { [unowned self] in
                let annotations = selectedTargetAnnotation($0, annotations: self.mapView.annotations)
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations(annotations)
            }
            .addDisposableTo(disposeBag)
        
        let current = Observable.merge(selected, didSelect)
        
        current.map { $0.name }
            .bindTo(nameOutlet.rx.text)
            .addDisposableTo(disposeBag)
        
        current.map { $0.address }
            .bindTo(addressOutlet.rx.text)
            .addDisposableTo(disposeBag)
        
        let geolocationService = GeolocationService.instance
        let navlocations = Observable.combineLatest(current, geolocationService.location.asObservable()) { ($0.0.coordinate, $0.1) }
        
        navOutlet.rx.tap.asObservable()
            .withLatestFrom(navlocations)
            .bindNext {
                MapUtility.navigation(originLocation: $1, toLocation: $0)
            }
            .addDisposableTo(disposeBag)
    }
    
}

extension AllKidsLocationController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? TargetAnnotation else {
            return nil
        }
        
        let reuseIdentifier = "targetAnnoteationReuseIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? HeadPortraitAnnotationView
        if annotationView == nil {
            annotationView = HeadPortraitAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
        }
        
        annotationView?.type =  annotation.selected ? .big : .medium
        annotationView?.setHeadPortrait(name: annotation.name ?? "", url: annotation.url ?? "")
        
        return annotationView
    }
    
}


func calculateCentreDistance(_ annotations: [TargetAnnotation]) -> (CLLocationCoordinate2D, CLLocationDistance) {
    let centre = annotations.filter({ $0.selected }).first?.coordinate ?? (annotations.first?.coordinate)!
    let minDistance = 200.0
    guard annotations.count > 1 else {
        return (centre, minDistance)
    }
    let centreLocation = CLLocation(latitude: centre.latitude, longitude: centre.longitude)
    let distance = annotations.map{ $0.coordinate }.map{ CLLocation(latitude: $0.latitude, longitude: $0.longitude) }.map{ $0.distance(from: centreLocation) }.max() ?? minDistance
    return (centre, distance > minDistance ? distance : minDistance)
}

fileprivate func selectedTargetAnnotation(_ target: TargetAnnotation, annotations: [MKAnnotation]) -> [TargetAnnotation] {
    return annotations.flatMap{ $0 as? TargetAnnotation }.map { $0.clone(selected: $0 == target) }
}

fileprivate func transform(currId: String, devices: [DeviceInfo], locations: [KidSate.LocationInfo]) -> [TargetAnnotation] {
    let count = (devices.count > locations.count) ? locations.count : devices.count
    var annotations: [TargetAnnotation] = []
    for i in 0 ..< count {
        if let coordinate = locations[i].location {
            let anno = TargetAnnotation(coordinate, name: devices[i].user?.nickname, address: locations[i].address, url: devices[i].user?.profile)
            anno.selected = devices[i].deviceId == currId
            annotations.append(anno)
        }
    }
    return annotations
}

