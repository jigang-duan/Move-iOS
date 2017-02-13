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
    
    var item : UIBarButtonItem?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.title = "Location History"
        
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
                self.locationMap.removeAnnotations(self.locationMap.annotations)
                self.locationMap.addAnnotation(annotion)
            })
            .addDisposableTo(disposeBag)
        
        // Do any additional setup after loading the view.
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

}

extension LocationHistoryVC : MKMapViewDelegate {
    
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
}
