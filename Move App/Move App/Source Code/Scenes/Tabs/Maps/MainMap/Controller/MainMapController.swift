//
//  MainMapController.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/9.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa
import SVPulsingAnnotationView
import Realm
import RealmSwift

//private extension Reactive where Base: MKMapView {
//    var singleAnnotion: UIBindingObserver<Base, MKAnnotation> {
//        return UIBindingObserver(UIElement: base) { mapView, annotion in
//            mapView.removeAnnotations(mapView.annotations)
//            mapView.addAnnotation(annotion)
//        }
//    }
//}

class MainMapController: UIViewController {
    
    var disposeBag = DisposeBag()
    var isOpenList : Bool? = false
    
    var userLocation : CLLocationCoordinate2D?
    var selectLocation : CLLocationCoordinate2D?
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet var noGeolocationView: UIView!
    @IBOutlet weak var openPreferencesBtn: UIButton!
    
    @IBOutlet weak var objectImageBtn: UIButton!
    @IBOutlet weak var objectNameL: UILabel!
    @IBOutlet weak var objectNameLConstraintWidth: NSLayoutConstraint!
    @IBOutlet weak var objectLocationL: UILabel!
    @IBOutlet weak var signalImageV: UIImageView!
    @IBOutlet weak var electricV: UIImageView!
    @IBOutlet weak var electricL: UILabel!
    @IBOutlet weak var objectLocationTimeL: UILabel!
    
    var accountViewModel: AccountAndChoseDeviceViewModel!
    let enterCount = Variable(0)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.title = "Location"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noGeolocationView.frame = view.bounds
        view.addSubview(noGeolocationView)
        let geolocationService = GeolocationService.instance
        
        let viewModel = MainMapViewModel(
            input: (
                avatarTap: objectImageBtn.rx.tap.asDriver(),
                avatarView: objectImageBtn
            ),
            dependency: (
                geolocationService: geolocationService,
                deviceManager: DeviceManager.shared,
                locationManager: LocationManager.share
            )
        )
        
        viewModel.selecedAction
            .bindNext({
                Logger.info($0)
                self.KidInfoToAnimation(dataSource: $0)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.authorized
            .drive(noGeolocationView.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        openPreferencesBtn.rx.tap
            .bindNext { [weak self] in
                self?.openAppPreferences()
            }
            .addDisposableTo(disposeBag)
        
        mapView.rx.willStartLoadingMap
            .asDriver()
            .drive(onNext: {
                Logger.debug("地图开始加载!")
            })
            .addDisposableTo(disposeBag)
        
        mapView.rx.didFinishLoadingMap
            .asDriver()
            .drive(onNext: {
                Logger.debug("地图结束加载!")
            })
            .addDisposableTo(disposeBag)
        
        mapView.rx.didAddAnnotationViews
            .asDriver()
            .drive(onNext: {
                Logger.debug("地图Annotion个数: \($0.count)")
            })
            .addDisposableTo(disposeBag)
        
        viewModel.kidLocation
            .asObservable()
            .take(1)
            .bindNext { [unowned self] in
                let region = MKCoordinateRegionMakeWithDistance($0, 500, 500)
                self.mapView.setRegion(region, animated: true)
            }
            .addDisposableTo(disposeBag)
        
        viewModel.kidAnnotion
            .distinctUntilChanged()
            .drive(onNext: { [unowned self] annotion in
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotation(annotion)
        })
            .addDisposableTo(disposeBag)
        
        
        
    }
    
    @IBAction func locationBtnClick(_ sender: UIButton) {
        
    }
    
    @IBAction func routeBtnClick(_ sender: UIButton) {
        
    }
    
    @IBAction func turnToStepCounterBtnClick(_ sender: UIButton) {
        
    }
    
    @IBAction func MobilePhoneBtnClick(_ sender: UIButton) {
        
    }
    
    @IBAction func MobileMessageBtnClick(_ sender: UIButton) {
        
    }
    
    @IBAction func GuideToWalk(_ sender: UIButton) {
        mapView.removeOverlays(mapView.overlays)
        if (userLocation == nil || selectLocation == nil ){
            return
        }
        self.goSearch(fromCoordinate: userLocation!, tofromCoordinate: selectLocation!)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func openAppPreferences() {
        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
    }
    
    func KidInfoToAnimation(dataSource : BasePopoverAction) {
        if dataSource.title == "ALL" {
            self.navigationController?.pushViewController((self.storyboard?.instantiateViewController(withIdentifier: "AllKidsLocationVC"))!, animated: true)
        }else {
            objectNameL.text = dataSource.title
            
            let device : MoveApi.DeviceInfo? = dataSource.data as? MoveApi.DeviceInfo
            if device?.property != nil {
                let property : MoveApi.DeviceProperty = (device?.property)!
                let power = (property.power)!
                electricL.text = String(format:"%d%",(property.power)!)
                if power == 0{
                    electricV.image = UIImage(named: "home_ic_battery0")
                }else if power < 20 && power > 0{
                    electricV.image = UIImage(named: "home_ic_battery1")
                }else if power < 40 && power > 20 {
                    electricV.image = UIImage(named: "home_ic_battery2")
                }else if power < 60 && power > 40 {
                    electricV.image = UIImage(named: "home_ic_battery3")
                }else if power < 80 && power > 60 {
                    electricV.image = UIImage(named: "home_ic_battery4")
                }else if power < 100 && power > 80 {
                    electricV.image = UIImage(named: "home_ic_battery5")
                }
            }
        }
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
}

extension MainMapController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is BaseAnnotation {
            let identifier = "LocationAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = ContactAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            annotationView?.canShowCallout = false
            return annotationView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //        let render = MKPolygonRenderer(overlay: overlay)
        //        render.strokeColor = UIColor.redColor()
        //        render.lineWidth = 4.0
        //        return render
        //        if overlay is MKPolyline {
        let  polylineRenderer = MKPolylineRenderer(overlay: overlay)
        //      polylineRenderer.lineDashPattern = [14,10,6,10,4,10]
        polylineRenderer.strokeColor = UIColor.red
        //      polylineRenderer.strokeColor = UIColor(red: 0.012, green: 0.012, blue: 0.012, alpha: 1.00)
        polylineRenderer.fillColor = UIColor.blue
        polylineRenderer.lineWidth = 2.5
        return polylineRenderer
    }
}
