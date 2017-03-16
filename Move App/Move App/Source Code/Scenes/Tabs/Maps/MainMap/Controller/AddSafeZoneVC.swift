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

class AddSafeZoneVC: UIViewController {

    var currentRadius :Double = 600
    var kidOverlay: MKCircle!
    var circleOverlay:MKCircle?
    var blPinChBegin = false


    var disposeBag = DisposeBag()
    var isOpenList : Bool? = false
    
    @IBOutlet var circleBorderView: NoEventView!
    
    @IBOutlet weak var nameTitleL: UILabel!
    @IBOutlet weak var addressTitleL: UILabel!
    
    @IBOutlet weak var kidnameL: UILabel!
    @IBOutlet weak var kidaddressL: UILabel!
    
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var RadiusL: UILabel!
    @IBOutlet weak var safeZoneSlider: UISlider!
    
    var centerss : CLLocationCoordinate2D?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.title = "Add Safe zone"
        
        let item=UIBarButtonItem(title : "Save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightBarButtonClick))
        self.navigationItem.rightBarButtonItem=item
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.circleBorderView.setNeedsDisplay()
        //self.circleBorderView.isHidden = true
    }
    
    func rightBarButtonClick (sender : UIBarButtonItem){
        
    }
    
    func actionFenceRadiusValueChanged(_ slider:UISlider) {
        
        self.currentRadius = Double(slider.value)
        self.drawOverlay(radius: self.currentRadius)
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
        
        let genametdata = MoveApi.Device.getDeviceInfo(deviceId: Me.shared.currDeviceID!)
            .map({
                self.kidaddressL.text = $0.user?.nickname
            })
        genametdata.subscribe(onNext: {
            print($0)
        }).addDisposableTo(disposeBag)
        
        let getaddressdata = MoveApi.Location.getNew(deviceId: Me.shared.currDeviceID!)
            .map({
                self.kidaddressL.text = $0.location?.addr
        })
        getaddressdata.subscribe(onNext: {
            print($0)
        }).addDisposableTo(disposeBag)
        
        centerss = mainMapView.centerCoordinate
        let img = UIImage(named : "general_slider_dot")
        safeZoneSlider.setThumbImage(img, for: UIControlState.normal)
        self.safeZoneSlider!.addTarget(self, action: #selector(actionFenceRadiusValueChanged(_:)), for: .valueChanged)

        let geolocationService = GeolocationService.instance
        let locationManager = LocationManager.share
        
        let viewModel = SafeZoneViewModel.init(input: (), dependency: (
            geolocationService: geolocationService,
            locationManager: locationManager,
            kidinfo: MokKidInfo()
        ))
        
        
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
            .bindNext { [unowned self] in
                let region = MKCoordinateRegionMakeWithDistance($0, 1500, 1500)
                self.mainMapView.setRegion(region, animated: true)
            }
            .addDisposableTo(disposeBag)
        
        viewModel.kidAnnotion.debug()
            .distinctUntilChanged()
            .drive(onNext: { [unowned self] annotion in
                self.mainMapView.removeAnnotations(self.mainMapView.annotations)
                self.mainMapView.addAnnotation(annotion)
                if self.circleOverlay == nil
                {
                    self.circleOverlay = MKCircle(center: annotion.coordinate, radius: self.currentRadius)
                    self.mainMapView.add(self.circleOverlay!)
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
    
    private var rectFromCoordinate : CGRect  {
        let region = MKCoordinateRegionMakeWithDistance(self.mainMapView.centerCoordinate, self.currentRadius, self.currentRadius)
        return mainMapView.convertRegion(region, toRectTo: self.circleBorderView)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

class CPinchGuesture :UIPinchGestureRecognizer {
    
    func canBePreventedByGestureRecognizer(_ gestureRecognizer:UIGestureRecognizer) ->Bool{
        return false
    }
    
    func canPreventGestureRecognizer(_ gestureRecognizer:UIGestureRecognizer) ->Bool{
        return false
    }
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
