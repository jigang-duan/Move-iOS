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
    var fenceName : String? = ""
    var fencelocation : CLLocationCoordinate2D?
    var fenceActive: Bool?
    var fences: [KidSate.ElectronicFencea] = []
    var currentRadius :Double = 600
    var kidOverlay: MKCircle!
    var circleOverlay:MKCircle?
    var blPinChBegin = false
    
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
    
    var centerss : CLLocationCoordinate2D?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let item=UIBarButtonItem(title : "Save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightBarButtonClick))
        self.navigationItem.rightBarButtonItem=item
        
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.circleBorderView.setNeedsDisplay()
        //self.circleBorderView.isHidden = true
    }
    
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
         RadiusL.text = String.init(format: "Radius:"+"%.fm", safeZoneSlider.value)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.kidnameTF.placeholder = "Enter a name for this safezone"
        if (self.editFenceDataSounrce != nil) {
            //编辑
            self.title = self.editFenceDataSounrce?.name
            self.kidnameTF.text = self.editFenceDataSounrce?.name
            self.kidaddressTF.text = self.editFenceDataSounrce?.location?.address
            self.fencelocation = CLLocationCoordinate2D(latitude: (self.editFenceDataSounrce?.location?.location?.latitude)!, longitude: (self.editFenceDataSounrce?.location?.location?.longitude)!)
            let region = MKCoordinateRegionMakeWithDistance( self.fencelocation!, 1500, 1500)
            self.mainMapView.setRegion(region, animated: true)
            safeZoneSlider.value = Float((self.editFenceDataSounrce?.radius)!)
            self.currentRadius = (self.editFenceDataSounrce?.radius)!
            self.mainMapView.removeAnnotations(self.mainMapView.annotations)
            let annotion = BaseAnnotation((self.fencelocation?.latitude)!, (self.fencelocation?.longitude)!)
            self.mainMapView.addAnnotation(annotion)
            if self.circleOverlay == nil
            {
                self.circleOverlay = MKCircle(center: annotion.coordinate, radius: self.currentRadius)
                self.mainMapView.add(self.circleOverlay!)
            }

        }else{
            //新增
            self.title = "Add Safe zone"
            let getaddressdata = MoveApi.Location.getNew(deviceId: Me.shared.currDeviceID!)
                .map({
                    self.kidaddressTF.text = $0.location?.addr
                    self.fencelocation = CLLocationCoordinate2D(latitude: ($0.location?.lat)!, longitude: ($0.location?.lng)!)
                    let region = MKCoordinateRegionMakeWithDistance( self.fencelocation!, 1500, 1500)
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
        
        mainMapView.rx.regionWillChangeAnimated
            .asDriver()
            .drive(onNext: { _ in
                if let overflay = self.circleOverlay {
                    self.mainMapView.remove(overflay)
                }
                
                self.circleBorderView.frame = self.mainMapView.bounds
                self.mainMapView.addSubview(self.circleBorderView)
                self.circleBorderView.radius = self.rectFromCoordinate.height
                self.circleBorderView.setNeedsDisplay()
            }).addDisposableTo(disposeBag)
        
        mainMapView.rx.regionDidChangeAnimated
            .asDriver().drive(onNext: {
                Logger.debug("地图 \($0)!")
                self.currentRadius = Double(self.safeZoneSlider.value)
                self.drawOverlay(radius: self.currentRadius)
                self.circleBorderView.removeFromSuperview()
                self.coordieToAddress()
            }).addDisposableTo(disposeBag)
        
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
            .bindNext {[unowned self] in
                let region = MKCoordinateRegionMakeWithDistance($0, 1500, 1500)
                print("\(region)")
//                self.mainMapView.setRegion(region, animated: true)
            }
            .addDisposableTo(disposeBag)
        
        viewModel.kidAnnotion.debug()
            .distinctUntilChanged()
            .drive(onNext: {[unowned self] annotion in
//                self.mainMapView.removeAnnotations(self.mainMapView.annotations)
//                self.mainMapView.addAnnotation(annotion)
                if self.circleOverlay == nil
                {
//                    self.circleOverlay = MKCircle(center: annotion.coordinate, radius: self.currentRadius)
//                    self.mainMapView.add(self.circleOverlay!)
                }
            })
            .addDisposableTo(disposeBag)
        

        // Do any additional setup after loading the view.
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
                    if (p.name != nil) {
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
                                }else{
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }).addDisposableTo(self.disposeBag)
                    }
                }
            } else {
                self.errorshow(message: "Enter a new, previously unused name.")
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
        })
        
//        alertController.addTextField { (textField : UITextField!) -> Void in
//            self.nameTextField = textField
//            self.nameTextField.placeholder = "Enter Name"
//        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func EditSafeZone() {
        let alertController = UIAlertController(title: "Confirm Did Edited ?", message: "", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            if self.kidnameTF.text != "" {
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
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
        })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
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
    
}

extension AddSafeZoneVC : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is BaseAnnotation {
            let reuseIdentifier = "targetAnnoteationReuseIdentifier"
            var annoView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? SVPulsingAnnotationView
            if annoView == nil {
                annoView = SVPulsingAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                annoView?.annotationColor = R.color.appColor.primary()
            }
            annoView?.canShowCallout = false
            return annoView
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
