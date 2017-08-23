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
import FSCalendar

class LocationHistoryVC: UIViewController {
    var Sprofile : String! = ""
    var Snikename : String! = ""
    var disposeBag = DisposeBag()
    var isOpenList : Bool? = false
    var index : Int = 0
    var dataSource : Observable<MoveApi.LocationHistory>?
    
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
        
    @IBOutlet weak var marBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var noLocatlonDescribeOutlet: UILabel!
    
    
    var isCalendarOpen : Bool = false
    
    var item : UIBarButtonItem?
    
    var routeLine : MKPolyline?
    
    var points : [MKMapPoint]?
    
    var deviceId : String?
    
    var selectedDate = Variable(Date())
    var LocationsVariable: Variable<[KidSate.LocationInfo]> = Variable([])
    
    
    func rightBarButtonClick (sender : UIBarButtonItem){
        if self.annotationArr.count > 0 {
            if isOpenList == false {
                
                sender.image = R.image.nav_slider_nor()
                addressDetailL.isHidden = true
                timeZoneSlider.isHidden = false
                isOpenList = true
            }else {
                
                sender.image = R.image.nav_location_nor()
                addressDetailL.isHidden = false
                timeZoneSlider.isHidden = true
                isOpenList = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = R.string.localizable.id_location_history()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.nav_location_nor(), style: .plain, target: self, action: #selector(rightBarButtonClick))
        noLocatlonDescribeOutlet.text = R.string.localizable.id_history_no_day()
        noLocatlonDescribeOutlet.adjustsFontSizeToFitWidth = true
        
        calendar.select(calendar.today)
        calendar.placeholderType = .none
        calendar.appearance.caseOptions = .weekdayUsesSingleUpperCase
        
        timeSelectBtn.setTitle(R.string.localizable.id_today(), for: .normal)
        
        timeZoneSlider.addTarget(self, action: #selector(actionFenceRadiusValueChanged(_:)), for: .valueChanged)
        
        locationMap.rx.willStartLoadingMap.asDriver()
            .drive(onNext: { Logger.debug("地图开始加载!") })
            .addDisposableTo(disposeBag)
        
        locationMap.rx.didFinishLoadingMap.asDriver()
            .drive(onNext: { Logger.debug("地图结束加载!") })
            .addDisposableTo(disposeBag)
        
        locationMap.rx.didAddAnnotationViews.asDriver()
            .drive(onNext: { Logger.debug("地图Annotion个数: \($0.count)") })
            .addDisposableTo(disposeBag)

        
        let historyLocations = selectedDate.asDriver()
            .map{ $0.todayStartEnd }
            .flatMapLatest{
                LocationManager.share.getHistoryLocation(start: $0, end: $1)
                    .catchErrorEmpty()
                    .asDriver(onErrorJustReturn: [])
            }
            .map{ items in items.sorted { $0.time!.compare($1.time!) == .orderedAscending } }
        
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
//                    self.marBottomConstraint.constant = 0
                    self.bottomView.isHidden = true
                    
                }else{
                    self.bottomViewheight.constant = 80
                    self.marBottomConstraint.constant = 0
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
                    self.index = self.annotationArr.count - 1
                    self.timeZoneSlider.maximumValue = Float(self.annotationArr.count - 1)
                    self.timeZoneSlider.minimumValue = 0
                    self.timeZoneSlider.value = Float(self.annotationArr.count - 1)
                    self.timePointSelect(index: self.annotationArr.count - 1)
                }
                
            })
            .addDisposableTo(disposeBag)
    }
    
    func actionFenceRadiusValueChanged(_ slider:UISlider ) {
        updateTagAnnotations(tagIndex: Int(slider.value))
    }
    
    fileprivate func updateTagAnnotations(tagIndex: Int) {
        locationMap.removeAnnotations(self.locationMap.annotations)
        if annotationArr.count > 0 {
            index = tagIndex
            self.locationMap.addAnnotations(self.annotationArr)
            self.timePointSelect(index: index)
            locationMap.setCenter(annotationArr[index].coordinate, animated: true)

            let region : MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(annotationArr[index].coordinate, 350, 350);
            locationMap .setRegion(region, animated: true)
        }
    }
    
    func timePointSelect(index : Int) {
        if self.annotationArr.count > 0 {
            let annotation = annotationArr[index]
            
            let datestr = String(format: "(%d/%d)%@", annotation.tag + 1, annotationArr.count, (annotation.info?.time?.stringDefaultDescription)!)
            timeZoneL.text = datestr
            timeZoneL.adjustsFontSizeToFitWidth = true
            addressDetailL.text = annotation.info?.address
            locationMap.removeOverlays(locationMap.overlays)
            locationMap.add(MKCircle(center: (annotation.info?.location)!, radius: (annotation.info?.accuracy ?? 0)!))
        }
    }
    
    var annotationArr = [TagAnnotation]()
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    
    @IBAction func LastBtnClick(_ sender: UIButton) {
        guard
            let curday = calendar.selectedDate,
            let perivday = Calendar.current.date(byAdding: .day, value: -1, to: curday) else {
                return
        }
        calendar.select(perivday)
        let time = self.calenderConversion(from: calendar.today!, to: perivday)
        self.changeBtnType(time: time , date: perivday)
        selectedDate.value = perivday
        index = 0

    }
    
    @IBAction func NextBtnClick(_ sender: UIButton) {
        guard
            let curday = calendar.selectedDate,
            let nextday = Calendar.current.date(byAdding: .day, value: 1, to: curday) else {
                return
        }
        
        calendar .select(nextday)
        let time = self.calenderConversion(from: calendar.today!, to: nextday)
        self.changeBtnType(time: time , date: nextday)
        selectedDate.value = nextday
        index = 0

    }
    
    @IBAction func NextPointClick(_ sender: UIButton) {
        guard annotationArr.count > 0 else { return }
        guard index < self.annotationArr.count - 1 else { return }
        
        index += 1
        updateTagAnnotations(tagIndex: index)
        self.timeZoneSlider.value = Float(index)
    }

    @IBAction func LastPointClick(_ sender: UIButton) {
        guard annotationArr.count > 0 else { return }
        guard index > 0 else { return }
        
        index -= 1
        updateTagAnnotations(tagIndex: index)
        self.timeZoneSlider.value = Float(index)
    }
    
    func changeBtnType(time: Int, date: Date){
        timeNextBtn.setImage(UIImage(named: "general_next"), for: .normal)
        timeNextBtn.isEnabled = true
        if time == -1 {
            timeSelectBtn.setTitle(R.string.localizable.id_yesterday(), for: .normal)
        } else if time == 0 {
            timeSelectBtn.setTitle(R.string.localizable.id_today(), for: .normal)
            
            timeNextBtn.setImage(UIImage(named: "general_next_dis"), for: .normal)
            timeNextBtn.isEnabled = false
        } else {
            timeSelectBtn.setTitle(date.stringDefaultYearMonthDay, for: .normal)
        }
        locationMap.removeOverlays(locationMap.overlays)
        
    }
    
    func calenderConversion(from : Date,to : Date) -> Int {
        return Calendar.current.dateComponents([.day], from: from, to: to).day!
    }
}

extension LocationHistoryVC : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is TagAnnotation else { return nil }
        let point = annotation as! TagAnnotation
        
        let reuseIdentifier = "targetAnnoteationReuseIdentifier"
        var annoView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        if annoView == nil {
            annoView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
        }
        
        if point.tag == index {
            annoView?.image = R.image.positioning_ic_1()
        } else if let type = point.info?.type, type.set.contains(.sos) {
            annoView?.image = R.image.history_dot_sos_pre()
        } else {
            annoView?.image = R.image.history_dot_nor()
        }
        
        annoView?.canShowCallout = false
        return annoView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard view.annotation is TagAnnotation else { return }
        let point = view.annotation as! TagAnnotation
        
        index = point.tag
        updateTagAnnotations(tagIndex: index)
        timeZoneSlider.value = Float(index)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRender = MKCircleRenderer(overlay: overlay)
        circleRender.fillColor = UIColor.cyan.withAlphaComponent(0.2)
        circleRender.lineWidth = 2
        return circleRender
    }
}

extension LocationHistoryVC: FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        calendar.isHidden = true
        isCalendarOpen = false
        let time = self.calenderConversion(from: calendar.today!, to: date)
        self.changeBtnType(time: time , date : date)
        selectedDate.value = date
        index = 0
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return date <= calendar.today!
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        return date > calendar.today! ? R.color.appColor.fourthlyText() : .black
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
