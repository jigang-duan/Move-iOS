//
//  AllKidsLocationVC.swift
//  Move App
//
//  Created by lx on 17/3/9.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa

class AllKidsLocationVC: UIViewController ,CLLocationManagerDelegate , MKMapViewDelegate{
    
    var disposeBag = DisposeBag()

    @IBOutlet weak var guideBtn: UIButton!
    var dataArr: [DeviceInfo] = []
    var locationOfDevice : [MoveApi.LocationOfDevice]? = []
    var annotationArr : [TagAnnotation]? = []
    
    @IBOutlet weak var addressL: UILabel!
    @IBOutlet weak var nameL: UILabel!
     var item : UIBarButtonItem?
    
    let locationManager:CLLocationManager = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!
    var userPoint : CLLocationCoordinate2D?
    var selectPoint : CLLocationCoordinate2D?
    var selectAnnotation : TagAnnotation?
    var curDirectionMode:MKDirectionsTransportType = .walking
    
    override func viewDidLoad() {
        super.viewDidLoad()
        item=UIBarButtonItem(image: R.image.nav_member_nor(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightBarButtonClick))
        self.navigationItem.rightBarButtonItem=item
        mapView.delegate = self
        locationManager.delegate = self
        //设置定位进度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //更新距离
        locationManager.distanceFilter = 100
        ////发送授权申请
        locationManager.requestAlwaysAuthorization()
        if (CLLocationManager.locationServicesEnabled())
        {
            //允许使用定位服务的话，开启定位服务更新
            locationManager.startUpdatingLocation()
            print("定位开始")
        }
        
        self.reloadkidlocation()
        // Do any additional setup after loading the view.
    }
//    var activity = MoveApi.Activity()
    
     func rightBarButtonClick (sender : UIBarButtonItem){
        self.reloadkidlocation()
    }
    
    func reloadkidlocation() {
        var deviceids : [MoveApi.LocationDeviceId]? = []
        for tel in dataArr {
            let device_id = MoveApi.LocationDeviceId(device_id : tel.deviceId)
            deviceids?.append(device_id)
        }
        let locationlist = MoveApi.LocationMultiReq(locations: deviceids)
        
        MoveApi.Location.getMultiLocations(with: locationlist).bindNext({
            
            self.locationOfDevice = $0.locations!
            self.mapView.removeAnnotations(self.mapView.annotations)
            for located in self.locationOfDevice! {
                let loc = CLLocationCoordinate2D(latitude: (located.location?.lat)!, longitude: (located.location?.lng)!)
                let annotation = TagAnnotation(loc)
                if let location = located.location {
                    annotation.info = KidSate.LocationInfo(location: location)
                }
                for tel in self.dataArr {
                    if tel.deviceId == located.device_id {
                        annotation.name = tel.user?.nickname
                        annotation.device_id = tel.deviceId
                        annotation.profile = tel.user?.profile
                    }
                }
                
                self.annotationArr?.append(annotation)
            }
            
            self.mapView.addAnnotations(self.annotationArr!)
            self.mapView.showAnnotations(self.annotationArr!, animated: true)
        }).addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goSearch(fromCoordinate:CLLocationCoordinate2D ,tofromCoordinate : CLLocationCoordinate2D){
        let fromPlaceMark = MKPlacemark(coordinate: fromCoordinate, addressDictionary: nil)
        let toPlaceMark = MKPlacemark(coordinate: tofromCoordinate, addressDictionary: nil)
        let fromItem = MKMapItem(placemark: fromPlaceMark)
        let toItem = MKMapItem(placemark: toPlaceMark)
        self.findDirectionsFrom(source: fromItem, destination: toItem)
    }
    
    func findDirectionsFrom(source:MKMapItem,destination:MKMapItem){
        let request = MKDirectionsRequest()
        request.source = source
        request.destination = destination
        request.transportType = MKDirectionsTransportType.walking
        request.requestsAlternateRoutes = true;
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if error == nil {
                self.showRoute(response: response!)
            }else{
                print("trace the error \(error?.localizedDescription)")
            }
        }
    }
    
    func showRoute(response:MKDirectionsResponse) {
        for route in response.routes {
            mapView.add(route.polyline,level: MKOverlayLevel.aboveRoads)
            let routeSeconds = route.expectedTravelTime
            let routeDistance = route.distance
            print("distance between two points is \(routeSeconds) and \(routeDistance)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //获取最新的坐标
        let currLocation:CLLocation = locations.last!
        userPoint = CLLocationCoordinate2D(latitude: currLocation.coordinate.latitude, longitude: currLocation.coordinate.longitude)
        print("123\(currLocation.course)")
        let annotation = BaseAnnotation.init(userPoint!)
        for an in mapView.annotations
        {
            if an is BaseAnnotation {
                mapView.removeAnnotation(an)
            }
        }
        mapView.addAnnotation(annotation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("定位出错拉！！\(error)")
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is BaseAnnotation {
            let identifier = "LocationAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            annotationView?.annotation = annotation
            annotationView?.image = R.image.history_dot_nor()
            annotationView?.canShowCallout = false
            return annotationView
        }
        
        if annotation is TagAnnotation {
            let reuseIdentifier = "targetAnnoteationReuseIdentifier"
            var annoView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
            let subannotation = annotation as! TagAnnotation
            if selectAnnotation == subannotation {
//                annoView = BigContactAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
//                (annoView as! BigContactAnnotationView).setAvatarImage(nikename: subannotation.name ?? "", profile: subannotation.profile ?? "")
                let headAnnoView = HeadPortraitAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                headAnnoView.type = .big
                headAnnoView.setHeadPortrait(name: subannotation.name ?? "", url: subannotation.profile ?? "")
                annoView = headAnnoView
            }else{
//                annoView = ContactAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
//                (annoView as! ContactAnnotationView).setAvatarImage(nikename: subannotation.name ?? "", profile: subannotation.profile ?? "")
                let headAnnoView = HeadPortraitAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                headAnnoView.type = .medium
                headAnnoView.setHeadPortrait(name: subannotation.name ?? "", url: subannotation.profile ?? "")
                annoView = headAnnoView
            }
            annoView?.annotation = annotation
            annoView?.canShowCallout = false
            return annoView
        }
        return nil
    }
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is TagAnnotation {
            let annot = view.annotation as! TagAnnotation
            nameL.text = annot.name
            addressL.text = annot.info?.address
            self.selectAnnotation = annot
            self.mapView.removeAnnotations(self.mapView.annotations)
             self.mapView.addAnnotations(self.annotationArr!)
        }
        
        
//        if view is MKAnnotationView {
//            let selectannotation = view.annotation as! TagAnnotation?
//            selectPoint = selectannotation?.coordinate
//            mapView.removeOverlays(mapView.overlays)
//            if (userPoint == nil || selectPoint == nil) {
//                return
//            }
//            self.goSearch(fromCoordinate: userPoint!, tofromCoordinate: selectPoint!)
//        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let  polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.blue
        polylineRenderer.fillColor = UIColor.blue
        polylineRenderer.lineWidth = 2.5
        return polylineRenderer
    }
    
    
    @IBAction func guideBtnClick(_ sender: UIButton) {
        if selectAnnotation != nil {
            guard let kidCoordinate = selectAnnotation?.coordinate else {
                return
            }
            
            /*
             guard let useCoordinate = self.mapView?.userLocation.coordinate else {
             return
             }
             */
            
            let options = [
                MKLaunchOptionsDirectionsModeKey: self.curDirectionMode == .walking ? MKLaunchOptionsDirectionsModeWalking : MKLaunchOptionsDirectionsModeDriving,
                ]
            let placemark = MKPlacemark(coordinate: kidCoordinate, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "\(selectAnnotation?.name ?? "")"
            mapItem.openInMaps(launchOptions: options)
        }
    }


}
