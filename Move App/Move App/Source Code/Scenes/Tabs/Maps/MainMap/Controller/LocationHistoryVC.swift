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
    var Sprofile : String! = ""
    var Snikename : String! = ""
    var disposeBag = DisposeBag()
    var isOpenList : Bool? = false
    var index : Int = 0
    var dataSource : Observable<MoveApi.LocationHistory>? 
        
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
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
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var bottomViewheight: NSLayoutConstraint!
        
    var isCalendarOpen : Bool = false
    
    var item : UIBarButtonItem?
    
    var routeLine : MKPolyline?
    
    var points : [MKMapPoint]?
    
    var deviceId : String?
    
    var selectedDate = Variable(Date())
    var LocationsVariable: Variable<[KidSate.LocationInfo]> = Variable([])
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.title = "Location History"
        let img=UIImage(named: "nav_location_nor")
        item=UIBarButtonItem(image: img, style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightBarButtonClick))
        self.navigationItem.rightBarButtonItem=item
    }
    
    func rightBarButtonClick (sender : UIBarButtonItem){
        if self.annotationArr.count > 0 {
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.select(calendar.today)
        
        
        timeSelectBtn.setTitle("Today", for: UIControlState.normal)
        let img = R.image.general_slider_dot()
        timeZoneSlider.setThumbImage(img, for: UIControlState.normal)
        timeZoneSlider.addTarget(self, action: #selector(actionFenceRadiusValueChanged(_:)), for: .valueChanged)
        
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
        //测试
//        self.routeLine = self.polyline()
//        if self.routeLine != nil {
//            locationMap.add(routeLine!)
//        }
        
        let historyLocations = selectedDate.asDriver()
            .map({  $0.todayStartEnd  })
            .flatMapLatest({
                LocationManager.share.getHistoryLocation(start: $0, end: $1)
                    .asDriver(onErrorJustReturn: [])
            })
        
        historyLocations.drive(LocationsVariable).addDisposableTo(disposeBag)
        
        LocationsVariable.asDriver()
            .map({
                $0.flatMap({ $ -> TagAnnotation?  in
                    if let location = $.location {
                        let annotation = TagAnnotation(location)
                        let info = KidSate.LocationInfo(location: location, address: $.address, accuracy: $.accuracy, time: $.time , type: $.type)
                        annotation.info = info
                        return annotation
                    }
                    return nil
                })
            })
            .drive(onNext: { [unowned self] in
                if $0.count == 0 {
                    self.locationMap.removeAnnotations(self.locationMap.annotations)
                    self.annotationArr.removeAll()
                    self.bottomViewheight.constant = 50
                    self.bottomView.isHidden = true
                    
                }else{
                    self.bottomViewheight.constant = 80
                    self.bottomView.isHidden = false
                    self.locationMap.removeAnnotations(self.locationMap.annotations)
                    self.locationMap.addAnnotations($0)
                    self.locationMap.showAnnotations($0, animated: true)
                    var arr = $0
                    for i in 0..<arr.count {
                        let annotation = arr[i]
                        annotation.tag = i
                        arr[i] = annotation
                    }
                    self.annotationArr = arr
                    self.timeZoneSlider.maximumValue = Float(self.annotationArr.count - 1)
                    self.timeZoneSlider.minimumValue = 0
                    self.timeZoneSlider.value = 0
                    self.TimePointSelect(index: self.index)
                }
                
            })
            .addDisposableTo(disposeBag)
    }
    
    func actionFenceRadiusValueChanged(_ slider:UISlider ) {
        locationMap.removeAnnotations(self.locationMap.annotations)
        if annotationArr.count>0 {
            index = Int(slider.value)
            self.locationMap.addAnnotations(self.annotationArr)
            self.TimePointSelect(index: index)
        }

    }
    
    func DefaultDatalabel(){
        
    }
    
    func TimePointSelect(index : Int){
        if self.annotationArr.count > 0 {
            let annotation = annotationArr[index]
            
            let datestr = String.init(format: "(%d/%d)%@", annotation.tag + 1 , annotationArr.count , (annotation.info?.time?.stringYearMonthDayHourMinuteSecond)!)
            timeZoneL.text = datestr
            addressDetailL.text = annotation.info?.address
        }
    }
    
    var annotationArr = [TagAnnotation]()
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func openAppPreferences() {
        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
    }
    //测试
//    func polyline() -> MKPolyline {
//        var coords = [CLLocationCoordinate2D]()
//        var locationarr = [TagAnnotation]()
//        for  i in 0...10  {
//            var location = CLLocationCoordinate2D()
//            if i%2 != 0 {
//                 location = CLLocationCoordinate2DMake(23.227465 + Double(i) * 0.002, 113.190765 + Double(i) * 0.002)
//            }else{
//                 location = CLLocationCoordinate2DMake(23.227465 - Double(i) * 0.002, 113.190765 - Double(i) * 0.002)
//            }
//            coords .append(location)
//            let annotation = TagAnnotation(location)
//            annotation.tag = i
//            locationarr.append(annotation)
//        }
//        locationMap.addAnnotations(locationarr)
//        return MKPolyline(coordinates : coords, count: coords.count)
//    }
    
    @IBAction func CalenderOpenBtnClick(_ sender: UIButton) {
        if isCalendarOpen == false {
            calendar.isHidden = false
            isCalendarOpen = true
        }else{
            calendar.isHidden = true
            isCalendarOpen = false
        }
        
    }
    
    
    @IBAction func LastBtnClick(_ sender: UIButton) {
        let curday = calendar.selectedDate
        let perivday = calendar.date(bySubstractingDays: 1, from: curday!)
        calendar.select(perivday)
        let time = self.calenderConversion(from: calendar.today!, to: perivday)
        self .changeBtnType(time: time , date : perivday)
        selectedDate.value = perivday
        index = 0
        //测试
//        self.routeLine = self.polyline()
//        if self.routeLine != nil {
//            locationMap.add(routeLine!)
//        }
    }
    
    @IBAction func NextBtnClick(_ sender: UIButton) {
        let curday = calendar.selectedDate
        let nextday = calendar.date(byAddingDays: 1, to: curday!)
        calendar .select(nextday)
        let time = self.calenderConversion(from: calendar.today!, to: nextday)
        self .changeBtnType(time: time , date : nextday)
        selectedDate.value = nextday
        index = 0
        //测试
//        self.routeLine = self.polyline()
//        if self.routeLine != nil {
//            locationMap.add(routeLine!)
//        }
    }
    
    @IBAction func NextPointClick(_ sender: UIButton) {
        locationMap.removeAnnotations(self.locationMap.annotations)
        if annotationArr.count>0 {
            if index == self.annotationArr.count - 1{
                
            }else {
                index += 1
            }
            self.locationMap.addAnnotations(self.annotationArr)
            self.TimePointSelect(index: index)
            self.timeZoneSlider.value = Float(index)
        }
        //测试
//        self.routeLine = self.polyline()
//        if self.routeLine != nil {
//            locationMap.add(routeLine!)
//        }
    }

    @IBAction func LastPointClick(_ sender: UIButton) {
        locationMap.removeAnnotations(self.locationMap.annotations)
        if annotationArr.count>0 {
            if index == 0 {
            }else {
                index -= 1
            }
            self.locationMap.addAnnotations(self.annotationArr)
            self.TimePointSelect(index: index)
            self.timeZoneSlider.value = Float(index)
        }
        //测试
//        self.routeLine = self.polyline()
//        if self.routeLine != nil {
//            locationMap.add(routeLine!)
//        }
    }
    
    
    func changeBtnType(time : Int , date : Date){
        if time == 1 {
            timeSelectBtn.setTitle("Tomorrow", for: UIControlState.normal)
        }else if time == -1 {
            timeSelectBtn.setTitle("Yesterday", for: UIControlState.normal)
        }else if time == 0{
            timeSelectBtn.setTitle("Today", for: UIControlState.normal)
        }else{
            let string = self.formatter.string(from: date)
            timeSelectBtn.setTitle(string, for: UIControlState.normal)
        }
        
    }
    
    func calenderConversion(from : Date , to : Date) -> Int {
        let gregorian = Calendar(identifier: Calendar.Identifier.chinese)
        let result = gregorian.dateComponents([Calendar.Component.day], from: from, to: to)
        return result.day!
    }
    
    func dateNowAsString(date : Date) -> String {

        let timeZone = TimeZone.init(identifier: "UTC")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = "yyyy-MM-dd"
        
        let datestr = formatter.string(from: date)
        return datestr
    }
    
    func timePointSelect(index : Int) {
        if annotationArr.count > 0 {
            
        }
    }
}

extension LocationHistoryVC : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is TagAnnotation {
            
            let point = annotation as! TagAnnotation
            if point.tag ==  index{
                let identifier = "LocationAnnotation"
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                if annotationView == nil {
                    //动态的
//                    annotationView = SVPulsingAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    
                }
                    annotationView?.image = R.image.positioning_ic_1()
                    annotationView?.canShowCallout = false
//                annotationView?.image = R.image.history_dot_pre()
//                (annotationView as! ContactAnnotationView).setAvatarImage(nikename: Snikename, profile: Sprofile)
                
                return annotationView
//                annoView?.image = UIImage(named : "history_dot_pre")
            }else{
                let reuseIdentifier = "targetAnnoteationReuseIdentifier"
                var annoView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
                if annoView == nil {
                    annoView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                }

                annoView?.image = R.image.history_dot_nor()
                
                annoView?.canShowCallout = false
                return annoView
            }
            
            //history_dot_pre选中
            
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is TagAnnotation {
            let point = view.annotation as! TagAnnotation
            index = point.tag
            self.locationMap.removeAnnotations(self.locationMap.annotations)
            if annotationArr.count > 0 {
                self.locationMap.addAnnotations(annotationArr)
                
                self.TimePointSelect(index: index)
                self.timeZoneSlider.value = Float(index)
            }
        }
    }
    
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        
//        if overlay is MKPolyline {
//            let polylineRenderer = MKPolylineRenderer(polyline : routeLine!)
//            polylineRenderer.fillColor = UIColor.red
//            polylineRenderer.strokeColor = R.color.appColor.primary()
//            polylineRenderer.lineWidth = 4.0
//            return polylineRenderer
//        }
//        return MKPolylineRenderer()
//    }
}

extension LocationHistoryVC : FSCalendarDelegate,FSCalendarDelegateAppearance{
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)
    {
        calendar.isHidden = true
        isCalendarOpen = false
        let time = self.calenderConversion(from: calendar.today!, to: date)
        self.changeBtnType(time: time , date : date)
        print("did select date \(self.formatter.string(from: date))")
        selectedDate.value = date
        index = 0
    }

}


fileprivate extension Date {
    
    var todayStartEnd: (Date, Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let datestr = formatter.string(from: self)
        let start = datestr + " 00:00:00"
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let startdate = formatter.date(from: start)
        let end = datestr + " 23:59:59"
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let enddate = formatter.date(from: end)
        return (startdate!, enddate!)
    }

}
