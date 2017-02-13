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

class AddSafeZoneVC: UIViewController {

    var disposeBag = DisposeBag()
    var isOpenList : Bool? = false
    
    @IBOutlet weak var nameTitleL: UILabel!
    @IBOutlet weak var addressTitleL: UILabel!
    
    @IBOutlet weak var kidnameL: UILabel!
    @IBOutlet weak var kidaddressL: UILabel!
    
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var RadiusL: UILabel!
    @IBOutlet weak var safeZoneSlider: UISlider!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.title = "Add Safe zone"
        
        let item=UIBarButtonItem(title : "Save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightBarButtonClick))
        self.navigationItem.rightBarButtonItem=item
    }
    
    func rightBarButtonClick (sender : UIBarButtonItem){
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let img = UIImage(named : "general_slider_dot")
        safeZoneSlider.setThumbImage(img, for: UIControlState.normal)
        
        let geolocationService = GeolocationService.instance
        
        let viewModel = MainMapViewModel(input: (),
                                         dependency: (
                                            geolocationService: geolocationService,
                                            kidInfo: MokKidInfo()
            )
        )
        
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
                let region = MKCoordinateRegionMakeWithDistance($0, 500, 500)
                self.mainMapView.setRegion(region, animated: true)
            }
            .addDisposableTo(disposeBag)
        
        viewModel.kidAnnotion.debug()
            .distinctUntilChanged()
            .drive(onNext: { [unowned self] annotion in
                self.mainMapView.removeAnnotations(self.mainMapView.annotations)
                self.mainMapView.addAnnotation(annotion)
            })
            .addDisposableTo(disposeBag)

        // Do any additional setup after loading the view.
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
}
