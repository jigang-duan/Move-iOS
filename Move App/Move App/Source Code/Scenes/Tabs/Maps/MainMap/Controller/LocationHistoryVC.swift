//
//  LocationHistoryVC.swift
//  Move App
//
//  Created by lx on 17/2/12.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa
import SVPulsingAnnotationView
import FSCalendar
class LocationHistoryVC: UIViewController {
    var disposeBag = DisposeBag()
    var isOpenList : Bool? = false
    @IBOutlet weak var locationMap: MKMapView!
    
    @IBOutlet weak var timeSelectBtn: UIButton!
    
    @IBOutlet weak var timeBackBtn: UIButton!
    
    @IBOutlet weak var timeNextBtn: UIButton!
    
    @IBOutlet weak var timeZoneL: UILabel!
    
    @IBOutlet weak var backPoint: UIButton!
    
    @IBOutlet weak var nextPoint: UIButton!
    
    @IBOutlet weak var addressDetailL: UILabel!
    
    @IBOutlet weak var timeZoneSlider: UISlider!
    
    @IBOutlet weak var calendar: FSCalendar!
    
    var isCalendarOpen : Bool = false
    
    var item : UIBarButtonItem?
    
    var routeLine : MKPolyline?
    
    var points : [MKMapPoint]?
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.title = "Location History"
        calendar.delegate = self
        let img=UIImage(named: "nav_location_nor")
        item=UIBarButtonItem(image: img, style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightBarButtonClick))
        self.navigationItem.rightBarButtonItem=item
    }
    
    func rightBarButtonClick (sender : UIBarButtonItem){
        
        if isOpenList == false {
            let img=UIImage(named: "nav_slider_nor")
            sender.image = img
            addressDetailL.isHidden = true
            timeZoneSlider.isHidden = false
            isOpenList = true
        }else {
            let img=UIImage(named: "nav_location_nor")
            sender.image = img
            addressDetailL.isHidden = false
            timeZoneSlider.isHidden = true
            isOpenList = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.select(calendar.today)
        timeSelectBtn.setTitle("Today", for: UIControlState.normal)
        let img = UIImage(named : "general_slider_dot")
        timeZoneSlider.setThumbImage(img, for: UIControlState.normal)
        
        let geolocationService = GeolocationService.instance
        
        let viewModel = MainMapViewModel(input: (),
                                         dependency: (
                                            geolocationService: geolocationService,
                                            kidInfo: MokKidInfo()
            )
        )
        
        locationMap.rx.willStartLoadingMap
            .asDriver()
            .drive(onNext: {
                Logger.debug("地图开始加载!")
            })
            .addDisposableTo(disposeBag)
        
        locationMap.rx.didFinishLoadingMap
            .asDriver()
            .drive(onNext: {
                Logger.debug("地图结束加载!")
            })
            .addDisposableTo(disposeBag)
        
        locationMap.rx.didAddAnnotationViews
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
                self.locationMap.setRegion(region, animated: true)
            }
            .addDisposableTo(disposeBag)
        
        viewModel.kidAnnotion.debug()
            .distinctUntilChanged()
            .drive(onNext: { [unowned self] annotion in
                
            })
            .addDisposableTo(disposeBag)
        
        // Do any additional setup after loading the view.
        
        self.routeLine = self.polyline()
        if self.routeLine != nil {
            locationMap.add(routeLine!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func openAppPreferences() {
        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func polyline() -> MKPolyline {
        var coords = [CLLocationCoordinate2D]()
        var locationarr = [LocationAnnotation]()
        for  i in 0...10  {
            var location = CLLocationCoordinate2D()
            if i%2 != 0 {
                 location = CLLocationCoordinate2DMake(23.227465 + Double(i) * 0.002, 113.190765 + Double(i) * 0.002)
            }else{
                 location = CLLocationCoordinate2DMake(23.227465 - Double(i) * 0.002, 113.190765 - Double(i) * 0.002)
            }
            coords .append(location)
            let annotation = LocationAnnotation(location)
            locationarr.append(annotation)
        }
        locationMap.addAnnotations(locationarr)
        return MKPolyline(coordinates : coords, count: 10)
    }
    
    @IBAction func CalenderOpenBtnClick(_ sender: UIButton) {
        if isCalendarOpen == false {
            calendar.isHidden = false
            isCalendarOpen = true
        }else{
            calendar.isHidden = true
            isCalendarOpen = false
        }
        
    }
    
    var selectDate = Date()
    
    @IBAction func LastBtnClick(_ sender: UIButton) {
        let curday = calendar.selectedDate
        let perivday = calendar.date(bySubstractingDays: 1, from: curday)
        calendar.select(perivday)
//        if perivday.compare(calendar.today!) == .orderedAscending {
        
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.unitsStyle = DateComponentsFormatter.UnitsStyle.full
        let diffString = dateComponentsFormatter.string(from: perivday, to: calendar.today!)
        
        print("\(diffString)")
//        }
    }
    @IBAction func NextBtnClick(_ sender: UIButton) {
        let curday = calendar.selectedDate
        let nextday = calendar.date(byAddingDays: 1, to: curday)
        calendar .select(nextday)
        
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.unitsStyle = DateComponentsFormatter.UnitsStyle.full
        let diffString = dateComponentsFormatter.string(from: nextday, to: calendar.today!)
        print("\(diffString)")
    }
    
    
}

extension LocationHistoryVC : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is LocationAnnotation {
            let identifier = "LocationAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            annotationView?.canShowCallout = false
            let detailImage = UIImage(named: "positioning_ic_1")
            annotationView?.image = detailImage
            return annotationView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(polyline : routeLine!)
            polylineRenderer.fillColor = UIColor.red
            polylineRenderer.strokeColor = R.color.appColor.primary()
            polylineRenderer.lineWidth = 4.0
            return polylineRenderer
        }
        return MKPolylineRenderer()
    }
}

extension LocationHistoryVC : FSCalendarDelegate,FSCalendarDelegateAppearance{
    
}
