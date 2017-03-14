//
//  AllKidsLocationVC.swift
//  Move App
//
//  Created by lx on 17/3/9.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class AllKidsLocationVC: UIViewController ,CLLocationManagerDelegate , MKMapViewDelegate{

        func addannotationData() {
            var coords = [CLLocationCoordinate2D]()
            var locationarr = [TagAnnotation]()
            for  i in 0...5  {
                var location = CLLocationCoordinate2D()
                if i%2 != 0 {
                     location = CLLocationCoordinate2DMake(23.227465 + Double(i) * 0.002, 113.190765 + Double(i) * 0.002)
                }else{
                     location = CLLocationCoordinate2DMake(23.227465 - Double(i) * 0.002, 113.190765 - Double(i) * 0.002)
                }
                coords .append(location)
                let annotation = TagAnnotation(location)
                annotation.tag = i
                locationarr.append(annotation)
            }
            mapView.addAnnotations(locationarr)
            mapView.showAnnotations(locationarr, animated: true)
        }
    
    let locationManager:CLLocationManager = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!
    var userPoint : CLLocationCoordinate2D?
    var selectPoint : CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        self.addannotationData()
        // Do any additional setup after loading the view.
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
        let annotation = LocationAnnotation.init(userPoint!)
        for an in mapView.annotations
        {
            if an is LocationAnnotation {
                mapView.removeAnnotation(an)
            }
        }
        mapView.addAnnotation(annotation)
        //        label1.text = "经度：\(currLocation.coordinate.longitude)"
        //        //获取纬度
        //        label2.text = "纬度：\(currLocation.coordinate.latitude)"
        //        //获取海拔
        //        label3.text = "海拔：\(currLocation.altitude)"
        //        //获取水平精度
        //        label4.text = "水平精度：\(currLocation.horizontalAccuracy)"
        //        //获取垂直精度
        //        label5.text = "垂直精度：\(currLocation.verticalAccuracy)"
        //        //获取方向
        //        label6.text = "方向：\(currLocation.course)"
        //        //获取速度
        //        label7.text = "速度：\(currLocation.speed)"
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("定位出错拉！！\(error)")
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is BaseAnnotation {
            let identifier = "LocationAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = ContactAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            annotationView?.annotation = annotation
            
            annotationView?.canShowCallout = false
            return annotationView
        }
        else if annotation is TagAnnotation || annotation is LocationAnnotation
        {
            let reuseIdentifier = "targetAnnoteationReuseIdentifier"
            var annoView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
            if annoView == nil {
                annoView = ContactAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            }
//            annoView?.image = UIImage(named : "history_dot_nor")
            annoView?.canShowCallout = false
            return annoView
        }
        return nil
    }
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view is MKAnnotationView {
            let selectannotation = view.annotation as! TagAnnotation?
            selectPoint = selectannotation?.coordinate
            mapView.removeOverlays(mapView.overlays)
            if (userPoint == nil || selectPoint == nil) {
                return
            }
            self.goSearch(fromCoordinate: userPoint!, tofromCoordinate: selectPoint!)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //        let render = MKPolygonRenderer(overlay: overlay)
        //        render.strokeColor = UIColor.redColor()
        //        render.lineWidth = 4.0
        //        return render
        //        if overlay is MKPolyline {
        let  polylineRenderer = MKPolylineRenderer(overlay: overlay)
        //      polylineRenderer.lineDashPattern = [14,10,6,10,4,10]
        polylineRenderer.strokeColor = UIColor.blue
        //      polylineRenderer.strokeColor = UIColor(red: 0.012, green: 0.012, blue: 0.012, alpha: 1.00)
        polylineRenderer.fillColor = UIColor.blue
        polylineRenderer.lineWidth = 2.5
        return polylineRenderer
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
