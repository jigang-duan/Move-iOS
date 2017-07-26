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
    @IBOutlet weak var infoOutlet: UIView!
    
    
    var targetId = Variable("")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = R.string.localizable.id_all_location()
        self.mapView.delegate = self
        
        let locations = Observable<Int>.timer(1, period: 30.0, scheduler: MainScheduler.instance)
            .withLatestFrom(RxStore.shared.deviceInfosObservable)
            .map { (devices) in devices.flatMap { $0.deviceId } }
            .flatMapLatest { LocationManager.share.locations(deviceIDs: $0).catchErrorJustReturn([]) }
        
        RxStore.shared.deviceIdObservable
            .bindTo(targetId)
            .addDisposableTo(disposeBag)
        
        let fetchAnnotations = Observable.combineLatest(targetId.asObservable().filterEmpty(),
                                                        RxStore.shared.deviceInfosObservable,
                                                        locations,
                                                        resultSelector: transform)
        
        let period = fetchAnnotations
            .filterEmpty()
            .share()
        
        let tap = barItemOutlet.rx.tap.asObservable()
            .withLatestFrom(fetchAnnotations)
            .filterEmpty()
            .share()
        
        let annotations = Observable.merge(period, tap)
            .filterEmpty()
            .share()
        
        period.single()
            .map{ calculateCentreDistance($0) }
            .map{ MKCoordinateRegionMakeWithDistance($0.0, $0.1, $0.1) }
            .bindTo(mapView.rx.region)
            .addDisposableTo(disposeBag)
        
        tap
            .map{ calculateCentreDistance($0) }
            .map{ MKCoordinateRegionMakeWithDistance($0.0, $0.1, $0.1) }
            .bindTo(mapView.rx.region)
            .addDisposableTo(disposeBag)
        
        annotations
            .bindNext { [unowned self] in
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations($0)
            }
            .addDisposableTo(disposeBag)
        
        annotations.filterEmpty()
            .map{_ in false}
            .bindTo(infoOutlet.rx.isHidden)
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
        
        didSelect
            .map { $0.targetId }.filterNil()
            .bindTo(targetId)
            .addDisposableTo(disposeBag)
        
        let current = Observable.merge(selected, didSelect).shareReplay(1)
        
        let name = current.map { $0.name }.filterNil()
        let location = current.map{ $0.coordinate }
            
        name.bindTo(nameOutlet.rx.text).addDisposableTo(disposeBag)
        current.map { $0.address }.bindTo(addressOutlet.rx.text).addDisposableTo(disposeBag)
        
        let navlocations = Observable.combineLatest(name, location) { ($0, $1) }
        
        navOutlet.rx.tap.asObservable()
            .withLatestFrom(navlocations)
            .bindNext { MapUtility.openPlacemark(name: $0, location: $1) }
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
            anno.targetId = devices[i].deviceId
            anno.selected = anno.targetId == currId
            annotations.append(anno)
        }
    }
    return annotations
}

