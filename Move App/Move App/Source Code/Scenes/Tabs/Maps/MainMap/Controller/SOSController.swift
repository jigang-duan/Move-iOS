//
//  SOSController.swift
//  Move App
//
//  Created by jiang.duan on 2017/4/12.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import CustomViews
import Kingfisher

class SOSController: UIViewController {
    
    var sos: KidSateSOS?
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var accuracyLabel: UILabel!
    @IBOutlet weak var sosCallLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var headPortrait: UIImageView!
    @IBOutlet weak var navigationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        typeLabel.text = sos?.type.description
        accuracyLabel.text = "\(sos?.location?.accuracy ?? 0.0) meters"
        sosCallLabel.text = "\(sos?.deviceInof?.user?.nickname ?? "kids") is making an SOS call"
        addressLabel.text = sos?.location?.address
        
        navigationButton.isEnabled = false
        if let location = sos?.location?.location {
            navigationButton.isEnabled = true
            mapView.delegate = self
            mapView.setRegion(MKCoordinateRegionMakeWithDistance(location, 500, 500), animated: true)
            mapView.addAnnotation(BaseAnnotation(location))
            if let radius = sos?.location?.accuracy {
                mapView.add(MKCircle(center: location, radius: radius))
            }
        }
        
        if let device = sos?.deviceInof {
            showHeadPortrait(deviceInfo: device)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillResignActive(_:)),
                                               name: NSNotification.Name.UIApplicationWillResignActive,
                                               object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func applicationWillResignActive(_ notification: NSNotification) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func navigationPressed(_ sender: UIButton) {
        if let location = sos?.location?.location {
            MapUtility.openPlacemark(name: sos?.deviceInof?.user?.nickname ?? "kids", location: location)
        }
    }
    
}

extension SOSController {
    
    fileprivate func showHeadPortrait(deviceInfo: DeviceInfo) {
        let placeImg = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0,
                                                      width: headPortrait.frame.size.width,
                                                      height: headPortrait.frame.size.height),
                                         fullName: deviceInfo.user?.nickname ?? "" )
            .imageRepresentation()!
        
        if let imgUrl = try? deviceInfo.user?.profile?.fsImageUrl.asURL() {
            self.headPortrait.kf.setImage(with: imgUrl, placeholder: placeImg)
        }
    }
    
}

extension SOSController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is BaseAnnotation {
            let identifier = "identifierSOSAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            annotationView?.image = R.image.history_dot_pre()
            annotationView?.canShowCallout = false
            return annotationView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRender = MKCircleRenderer(overlay: overlay)
        circleRender.fillColor = UIColor.cyan.withAlphaComponent(0.2)
        circleRender.strokeColor = R.color.appColor.wrong().withAlphaComponent(0.7)
        circleRender.lineWidth = 2
        return circleRender
    }
}


extension KidSateSOSType {
    
    var description: String {
        switch self {
        case .gps:
            return "GPS"
        case .bts:
            return "BTS"
        case .btsAndWifi:
            return "BTS+WiFi"
        default:
            return "none"
        }
    }
}
