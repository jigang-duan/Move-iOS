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

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet var noGeolocationView: UIView!
    @IBOutlet weak var openPreferencesBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noGeolocationView.frame = view.bounds
        view.addSubview(noGeolocationView)
        
        // Do any additional setup after loading the view.
        
        let geolocationService = GeolocationService.instance
        let viewModel = MainMapViewModel(input: (),
                                         dependency: (
                                            geolocationService: geolocationService,
                                            kidInfo: MokKidInfo()
            )
        )
        
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
        
        viewModel.kidAnnotion.debug()
            .distinctUntilChanged()
            .drive(onNext: { [unowned self] annotion in
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotation(annotion)
        })
            .addDisposableTo(disposeBag)
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

extension MainMapController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseIdentifier = "targetAnnoteationReuseIdentifier"
        var annoView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annoView == nil {
            annoView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
        }
        
        return annoView
    }
}
