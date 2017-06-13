//
//  AddSafeZoneVC.swift
//  Move App
//
//  Created by lx on 17/2/13.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa
import SVPulsingAnnotationView
import CustomViews

class AddSafeZoneVC: UIViewController , SearchVCdelegate {
    
    var editFenceDataSounrce : KidSate.ElectronicFencea?
    fileprivate var isEmptyFence = true
    
    var fenceName : String? = ""
    var fencelocation : CLLocationCoordinate2D?
    var fenceActive: Bool?
    var fences: [KidSate.ElectronicFencea] = []
    var currentRadius :Double = 600
    var kidOverlay: MKCircle!
    var circleOverlay:MKCircle?
    var blPinChBegin = false
    
    var item: UIBarButtonItem?
//    var nameTextField : UITextField!
    
    var disposeBag = DisposeBag()
    var isOpenList : Bool? = false
    
    @IBOutlet var circleBorderView: NoEventView!
    
    @IBOutlet weak var nameTitleL: UILabel!
    @IBOutlet weak var addressTitleL: UILabel!
    
    @IBOutlet weak var kidnameTF: UITextField!
    @IBOutlet weak var kidaddressTF: UITextField!
    
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var RadiusL: UILabel!
    @IBOutlet weak var safeZoneSlider: UISlider!
    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak var informationView1: UIView!
    @IBOutlet weak var mapTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapBottomContraint: NSLayoutConstraint!
    
    @IBOutlet weak var showaddressBtn: UIButton!
    var adminBool: Bool? = false

    
    var centerss : CLLocationCoordinate2D?
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        item = UIBarButtonItem(title : R.string.localizable.id_save(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightBarButtonClick))
        if self.adminBool!{
            self.navigationItem.rightBarButtonItem = item
        }
        
    }
    
//    fileprivate lazy var yellowDots: UIImageView = {
//        let imageView = UIImageView.init(image: R.image.positioning_ic_1())
//        
//        return imageView
//    }()
    
    func rightBarButtonClick (sender : UIBarButtonItem){
         if (self.editFenceDataSounrce != nil) {
            self.EditSafeZone()
         }else{
            self.SaveNewSafeZone()
        }
        
    }
    
    @IBAction func SearchBtnClick(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SafeZoneAddressSearchVC")  as! SafeZoneAddressSearchVC
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func actionFenceRadiusValueChanged(_ slider:UISlider) {
        
        self.currentRadius = Double(slider.value)
        self.drawOverlay(radius: self.currentRadius)
        RadiusL.text = String.init(format: "Radius:"+"%.fm"+"(200m~1000m)", safeZoneSlider.value)
    }
    
    func drawOverlay(radius:Double, centerCoordinate:CLLocationCoordinate2D? = nil) {
        var centerCoordinate = centerCoordinate
        centerCoordinate = centerCoordinate ?? self.mainMapView.centerCoordinate
        guard let coordinate = centerCoordinate, CLLocationCoordinate2DIsValid(coordinate) else {
            return
        }
        self.mainMapView.removeOverlays(self.mainMapView.overlays.filter { !$0.isEqual(self.kidOverlay) } )
        self.circleOverlay = MKCircle(center:coordinate, radius:radius)
        
        self.mainMapView.add(circleOverlay!)
        self.mainMapView.setNeedsDisplay()
    }
    
    func permissionsView(_ adminBool: Bool){
        self.informationView.isHidden = !adminBool
        self.informationView1.isHidden = !adminBool

        if adminBool{
            mapTopConstraint.constant = 0
            mapBottomContraint.constant = 0
        }else
        {
            mapTopConstraint.constant = -90
            mapBottomContraint.constant = -70
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.permissionsView(adminBool!)
        self.kidnameTF.placeholder = R.string.localizable.id_is_enter_safe_zone()
        if (self.editFenceDataSounrce != nil) {
            //编辑
            self.title = self.editFenceDataSounrce?.name
            self.kidnameTF.text = self.editFenceDataSounrce?.name
            self.kidaddressTF.text = self.editFenceDataSounrce?.location?.address
            self.fencelocation = CLLocationCoordinate2D(latitude: (self.editFenceDataSounrce?.location?.location?.latitude)!, longitude: (self.editFenceDataSounrce?.location?.location?.longitude)!)
            let region = MKCoordinateRegionMakeWithDistance( self.fencelocation!, 1500, 1500)
            self.mainMapView.setRegion(region, animated: true)
            safeZoneSlider.value = Float((self.editFenceDataSounrce?.radius)!)
//            self.currentRadius = (self.editFenceDataSounrce?.radius)!
            RadiusL.text = String.init(format: "Radius:"+"%.fm"+"(200m~1000m)", safeZoneSlider.value)
            self.mainMapView.removeAnnotations(self.mainMapView.annotations)
            self.currentRadius = Double(safeZoneSlider.value)
            self.drawOverlay(radius: self.currentRadius)
            let annotion = BaseAnnotation((self.fencelocation?.latitude)!, (self.fencelocation?.longitude)!)
            self.mainMapView.addAnnotation(annotion)
            if self.circleOverlay == nil
            {
                self.circleOverlay = MKCircle(center: annotion.coordinate, radius: self.currentRadius)
                self.mainMapView.add(self.circleOverlay!)
            }
            self.isEmptyFence = false
        }else{
            //新增
            self.title = "Add Safe zone"
            let getaddressdata = MoveApi.Location.getNew(deviceId: Me.shared.currDeviceID!)
                .map({
                   
                    self.kidaddressTF.text = $0.location?.addr
                    self.fencelocation = CLLocationCoordinate2D(latitude: ($0.location?.lat)!, longitude: ($0.location?.lng)!)
                    let region = MKCoordinateRegionMakeWithDistance(self.fencelocation!, 1500, 1500)
                    self.mainMapView.setRegion(region, animated: true)
                    self.mainMapView.removeAnnotations(self.mainMapView.annotations)
                    let annotion = BaseAnnotation((self.fencelocation?.latitude)!, (self.fencelocation?.longitude)!)
                    self.mainMapView.addAnnotation(annotion)
                    if self.circleOverlay == nil
                    {
                        self.circleOverlay = MKCircle(center: annotion.coordinate, radius: self.currentRadius)
                        self.mainMapView.add(self.circleOverlay!)
                    }
                })
            getaddressdata.subscribe(onNext: {
                print($0)
            }).addDisposableTo(disposeBag)
        }
        
        centerss = mainMapView.centerCoordinate
        let img = UIImage(named : "general_slider_dot")
        safeZoneSlider.setThumbImage(img, for: UIControlState.normal)
        self.safeZoneSlider!.addTarget(self, action: #selector(actionFenceRadiusValueChanged(_:)), for: .valueChanged)

        let geolocationService = GeolocationService.instance
        let locationManager = LocationManager.share
        
        let viewModel = SafeZoneViewModel(
            input: (),
            dependency: (
                geolocationService: geolocationService,
                locationManager: locationManager
            )
        )
        
//        mainMapView.showsUserLocation = true
        if adminBool! {
        mainMapView.rx.regionWillChangeAnimated
            .asDriver()
            .drive(onNext: { [weak self] _ in
                if let overflay = self?.circleOverlay {
                    self?.mainMapView.remove(overflay)
                }
                
                self?.circleBorderView.frame = (self?.mainMapView.bounds)!
                self?.mainMapView.addSubview((self?.circleBorderView)!)
                self?.circleBorderView.radius = (self?.rectFromCoordinate.height)!
                self?.circleBorderView.setNeedsDisplay()
            }).addDisposableTo(disposeBag)
        
        mainMapView.rx.regionDidChangeAnimated
            .asDriver()
            .drive(onNext: { [unowned self] in
                if self.isEmptyFence == false {
                Logger.debug("地图 \($0)!")
                self.currentRadius = Double(self.safeZoneSlider.value)
                self.drawOverlay(radius: self.currentRadius)
                self.circleBorderView.removeFromSuperview()
                self.coordieToAddress()
                }
                self.isEmptyFence = false
            }).addDisposableTo(disposeBag)
        }
        
        mainMapView.rx.willStartLoadingMap
            .asDriver()
            .drive(onNext: {
                Logger.debug("地图开始加载!")
            })
            .addDisposableTo(disposeBag)
        
        mainMapView.rx.didFinishLoadingMap
            .asDriver()
            .drive(onNext: {
                Logger.debug("地图结束加载!")
            })
            .addDisposableTo(disposeBag)
        
        mainMapView.rx.didAddAnnotationViews
            .asDriver()
            .drive(onNext: {
                Logger.debug("地图Annotion个数: \($0.count)")
            })
            .addDisposableTo(disposeBag)
        
        viewModel.kidLocation
            .asObservable()
            .take(1)
            .bindNext {[weak self] in
                let region = MKCoordinateRegionMakeWithDistance($0, 1500, 1500)
                print("\(region)")
//                self.mainMapView.setRegion(region, animated: true)
            }
            .addDisposableTo(disposeBag)
        
        viewModel.kidAnnotion.debug()
            .distinctUntilChanged()
            .drive(onNext: {[weak self] annotion in
//                self.mainMapView.removeAnnotations(self.mainMapView.annotations)
//                self.mainMapView.addAnnotation(annotion)
                if self?.circleOverlay == nil
                {
//                    self.circleOverlay = MKCircle(center: annotion.coordinate, radius: self.currentRadius)
//                    self.mainMapView.add(self.circleOverlay!)
                }
            })
            .addDisposableTo(disposeBag)
        

    }

    @IBAction func PinchToChangeZoom(_ sender: UIPinchGestureRecognizer) {
            
            switch sender.state {
            case .began:
                self.blPinChBegin = true
            case .changed:
                if self.circleBorderView.superview != nil {
                    self.circleBorderView.removeFromSuperview()
                    self.drawOverlay(radius: self.currentRadius)
                }
            case .ended,.cancelled:
                self.blPinChBegin = false
            default:
                break
            }

    }
    
    func coordieToAddress() {
        let geocoder = CLGeocoder()
        self.fencelocation = CLLocationCoordinate2D(latitude: self.mainMapView.centerCoordinate.latitude, longitude: self.mainMapView.centerCoordinate.longitude)
        let currentLocation = CLLocation(latitude: (self.fencelocation?.latitude)!, longitude: (self.fencelocation?.longitude)!)

        geocoder.reverseGeocodeLocation(currentLocation) { (pls: [CLPlacemark]?, error: Error?)  in
            if error == nil {
                let array = NSArray(object: "zh-hans")
                UserDefaults.standard.set(array, forKey: "AppleLanguages")
                if let p = pls?[0]{
                    //print(p) //输出反编码信息
                    
                    var address : String? = ""
                    if (p.name != nil ) {
                        address?.append(p.name!)
                        address = address! + " "
                    }
                    if (p.country != nil) {
                        address?.append(p.country!)
                    }
                    if (p.locality != nil) {
                        address?.append(p.locality!)
                    }
                    if (p.subLocality != nil) {
                        address?.append(p.subLocality!)
                    }
                    
                    if (p.thoroughfare != nil) {
                        address?.append(p.thoroughfare!)
                    }
                    self.kidaddressTF.text = address
                } else {
                    print("No placemarks!")
                }
            }else {
                print("错误")
            }
        }
    }
    
    private var rectFromCoordinate : CGRect  {
        let region = MKCoordinateRegionMakeWithDistance(self.mainMapView.centerCoordinate, self.currentRadius, self.currentRadius)
        return mainMapView.convertRegion(region, toRectTo: self.circleBorderView)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func Searchback(item: MKMapItem) {
        self.fencelocation = CLLocationCoordinate2D(latitude: (item.placemark.location?.coordinate.latitude)!, longitude: (item.placemark.location?.coordinate.longitude)!)
        
        var address : String? = item.name! + " "
        if (item.placemark.country != nil) {
            address?.append(item.placemark.country!)
        }
        if (item.placemark.locality != nil) {
            address?.append(item.placemark.locality!)
        }
        if (item.placemark.subLocality != nil) {
            address?.append(item.placemark.subLocality!)
        }
        
        if (item.placemark.thoroughfare != nil) {
            address?.append(item.placemark.thoroughfare!)
        }
        self.kidaddressTF.text = address
        let region = MKCoordinateRegionMakeWithDistance(self.fencelocation!, 1500, 1500)
        self.mainMapView.setRegion(region, animated: true)
    }
    
    
    func SaveNewSafeZone() {
        item?.isEnabled = false
        let alertController = UIAlertController(title: "Add New Name", message: "", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            if self.kidnameTF.text != "" {
                if (self.editFenceDataSounrce != nil) {
                    //编辑
                    var issame : Bool = false
                    for i in 0..<self.fences.count {
                        if ( self.editFenceDataSounrce?.ids != self.fences[i].ids ){
                            if self.fences[i].name == self.kidnameTF.text {
                                self.errorshow(message: "Enter a new, previously unused name.")
                                self.item?.isEnabled = true
                                issame = true
                            }
                        }
                    }
                    if issame == false {
                        let fenceloc : MoveApi.Fencelocation = MoveApi.Fencelocation(lat : self.fencelocation?.latitude,lng : self.fencelocation?.longitude, addr : self.kidaddressTF.text)
                        let fenceinfo : MoveApi.FenceInfo = MoveApi.FenceInfo(id : self.editFenceDataSounrce?.ids ,name : self.kidnameTF.text , location : fenceloc , radius : self.currentRadius , active : true)
                        let fencereq = MoveApi.FenceReq(fence : fenceinfo)
                        MoveApi.ElectronicFence.settingFence(fenceId : (self.editFenceDataSounrce?.ids)!, fenceReq: fencereq)
                            .subscribe(onNext: {
                                print($0)
                                if $0.msg != "ok" {
                                    self.errorshow(message: $0.field!)
                                }else{
                                  let _ = self.navigationController?.popViewController(animated: true)
                                }
                            }).addDisposableTo(self.disposeBag)
                    }
                }else{
                    //新增
                    var issame : Bool = false
                    for i in 0..<self.fences.count {
                            if self.fences[i].name == self.kidnameTF.text {
                                self.errorshow(message: "Enter a new, previously unused name.")
                                self.item?.isEnabled = true
                                issame = true
                            }
                    }
                    if issame == false {
                        let fenceloc : MoveApi.Fencelocation = MoveApi.Fencelocation(lat : self.fencelocation?.latitude,lng : self.fencelocation?.longitude, addr : self.kidaddressTF.text)
                        let fenceinfo : MoveApi.FenceInfo = MoveApi.FenceInfo(id : nil ,name : self.kidnameTF.text , location : fenceloc , radius : self.currentRadius , active : true)
                        let fencereq = MoveApi.FenceReq(fence : fenceinfo)
                        MoveApi.ElectronicFence.addFence(deviceId: Me.shared.currDeviceID!, fenceReq: fencereq)
                            .subscribe(onNext: {
                                print($0)
                                if $0.msg != "ok" {
                                    self.errorshow(message: $0.field!)
                                    self.item?.isEnabled = true
                                }else{
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }).addDisposableTo(self.disposeBag)
                    }
                }
            } else {
                self.errorshow(message: "Enter a new, previously unused name.")
                self.item?.isEnabled = true
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            self.item?.isEnabled = true
        })
        
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func EditSafeZone() {
       
        let alertController = UIAlertController(title: "Confirm Did Edited ?", message: "", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            alert ->  Void in
            if self.kidnameTF.text != "" {
                var asSame = false
                for i in 0..<self.fences.count {
                        if self.fences[i].name == self.kidnameTF.text {
                            asSame = true
                        
                    }
                }
                if asSame {
                    self.errorshow(message: "Enter a new, previously unused name.")
                    
                }else
                {
                    var fenceloc : MoveApi.Fencelocation? = nil
                    var fenceinfo : MoveApi.FenceInfo? = nil
                    var fencereq : MoveApi.FenceReq? = nil
                    if (self.fencelocation?.latitude == self.editFenceDataSounrce?.location?.location?.latitude )&&(self.fencelocation?.longitude == self.editFenceDataSounrce?.location?.location?.longitude){
                        fenceloc = MoveApi.Fencelocation(lat : self.fencelocation?.latitude,lng : self.fencelocation?.longitude, addr : self.editFenceDataSounrce?.location?.address)
                    }else{
                        fenceloc = MoveApi.Fencelocation(lat : self.fencelocation?.latitude,lng : self.fencelocation?.longitude, addr : self.kidaddressTF.text)
                    }
                    
                    fenceinfo = MoveApi.FenceInfo(id : (self.editFenceDataSounrce?.ids)! ,name : self.kidnameTF.text , location : fenceloc , radius : self.currentRadius , active : self.editFenceDataSounrce?.active)
                    fencereq = MoveApi.FenceReq(fence : fenceinfo)
                    
                    MoveApi.ElectronicFence.settingFence(fenceId: (self.editFenceDataSounrce?.ids)!, fenceReq: fencereq!).bindNext{
                        print($0)
                        if $0.msg != "ok" {
                            self.errorshow(message: $0.field!)
                            
                        }else{
                            let _ = self.navigationController?.popViewController(animated: true)
                        }
                        }.addDisposableTo(self.disposeBag)
                    
                }

                }
                
            
            //截断else
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
           
        })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }

    func errorshow(message : String) {
        let alertController = UIAlertController(title: "Save Error", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
        })
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

class CPinchGuesture :UIPinchGestureRecognizer {
    
    func canBePreventedByGestureRecognizer(_ gestureRecognizer:UIGestureRecognizer) ->Bool{
        return false
    }
    
    func canPreventGestureRecognizer(_ gestureRecognizer:UIGestureRecognizer) ->Bool{
        return false
    }
}

extension AddSafeZoneVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        view.endEditing(true)
        
        return true
    }

}

extension AddSafeZoneVC : MKMapViewDelegate {
    
    //黄点
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is BaseAnnotation {
            let identifier = "targetAnnoteationReuseIdentifier"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {               
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            annotationView?.image = R.image.positioning_ic_1()
            annotationView?.canShowCallout = false
            return annotationView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay.isEqual(self.circleOverlay) {
            let circleRender = MKCircleRenderer(overlay: overlay)
            circleRender.fillColor = UIColor.cyan.withAlphaComponent(0.2)
            circleRender.strokeColor = UIColor(red:0.450980, green:0.607843, blue:0.674510, alpha:1.0).withAlphaComponent(0.7)
            circleRender.lineWidth = 2
            return circleRender
        }
        
        return MKCircleRenderer(overlay: overlay)
    }
}
