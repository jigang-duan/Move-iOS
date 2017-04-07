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
import SVPulsingAnnotationView
import Realm
import RealmSwift
import MessageUI
import CustomViews


class MainMapController: UIViewController , MFMessageComposeViewControllerDelegate{
    
    var alertController : UIAlertController?
    var curDirectionMode:MKDirectionsTransportType = .walking

    var disposeBag = DisposeBag()
    
    var isOpenList = false
    var deviceInfos: [DeviceInfo] = []
    
    var userPoint : CLLocationCoordinate2D?
    var selectPoint : CLLocationCoordinate2D?
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet var noGeolocationView: UIView!
    @IBOutlet weak var openPreferencesBtn: UIButton!
    
    @IBOutlet weak var objectImageBtn: UIButton!
    @IBOutlet weak var objectNameL: UILabel!
    @IBOutlet weak var objectLocationL: UILabel!
    @IBOutlet weak var signalImageV: UIImageView!
    @IBOutlet weak var electricV: UIImageView!
    @IBOutlet weak var electricL: UILabel!
    @IBOutlet weak var objectLocationTimeL: UILabel!
    
    var currentDeviceData : BasePopoverAction?
    

    let enterCount = Variable(0)
    
    var isAtThisPage = Variable(false)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Location"
        self.isAtThisPage.value = true
        
        enterCount.value += 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isAtThisPage.value = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        noGeolocationView.frame = view.bounds
        view.addSubview(noGeolocationView)
        let geolocationService = GeolocationService.instance
        
        let viewModel = MainMapViewModel(
            input: (
                enterCount: enterCount.asDriver(),
                avatarTap: objectImageBtn.rx.tap.asDriver(),
                avatarView: objectImageBtn,
                isAtThisPage: isAtThisPage.asDriver()
            ),
            dependency: (
                geolocationService: geolocationService,
                deviceManager: DeviceManager.shared,
                locationManager: LocationManager.share
            )
        )
        
        viewModel.selecedAction
            .bindNext({ [weak self] action in
                Logger.info(action)
                self?.KidInfoToAnimation(dataSource: action)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.authorized
            .drive(noGeolocationView.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        openPreferencesBtn.rx.tap
            .bindNext { _ in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
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
            .bindNext({ [unowned self] in
                let region = MKCoordinateRegionMakeWithDistance($0, 500, 500)
                self.mapView.setRegion(region, animated: true)
                //self.GetCurrentNew()
            })
            .addDisposableTo(disposeBag)
        
        viewModel.kidAnnotion
            .distinctUntilChanged()
            .bindNext({ [unowned self] annotion in
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotation(annotion)
        })
        .addDisposableTo(disposeBag)
        
        
        
        viewModel.deviceInfos.drive(onNext: { [unowned self] deviceInfos in
            self.deviceInfos = deviceInfos
            
            var deviceInfo = DeviceInfo()
            
            if let idstr = DeviceManager.shared.currentDevice?.deviceId {
                for data in self.deviceInfos{
                    if data.deviceId == idstr {
                        deviceInfo = data
                    }
                }
            }else{
                if let data = self.deviceInfos.first {
                    deviceInfo = data
                }
            }
            
            guard let _ = deviceInfo.deviceId else {
                return
            }
            
            self.updateUIData(deviceInfo: deviceInfo)
            
            let action = BasePopoverAction(imageUrl: deviceInfo.user?.profile,
                                           placeholderImage: R.image.home_pop_all(),
                                           title: deviceInfo.user?.nickname,
                                           isSelected: true)
            action.canAvatar = true
            action.data = deviceInfo
            self.currentDeviceData = action
            let device = self.currentDeviceData?.data as? DeviceInfo
            let placeImg = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: self.objectImageBtn.frame.size.width, height: self.objectImageBtn.frame.size.height), fullName: device?.user?.nickname ?? "" ).imageRepresentation()!
            
            let imgUrl = URL(string: FSManager.imageUrl(with: device?.user?.profile ?? ""))
            self.objectImageBtn.kf.setBackgroundImage(with: imgUrl, for: .normal, placeholder: placeImg)
            
        })
        .addDisposableTo(disposeBag)
        
        
        
    }
    
    @IBAction func locationBtnClick(_ sender: UIButton) {
        if (currentDeviceData != nil) {
           self.GetCurrentNew()
        }
    }
    
    func GetCurrentNew() {
        if let _ = DeviceManager.shared.currentDevice?.deviceId {
            LocationManager.share.getCurrentLocation()
                .subscribe(onNext: {
                    let annotation = BaseAnnotation($0.location?.latitude ?? 0, $0.location?.longitude ?? 0)
                    self.objectLocationL.text = $0.address
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    self.mapView.addAnnotation(annotation)
                }, onError: { error in
                    if error is MoveApi.ApiError {
                        if let err = error as? MoveApi.ApiError  {
                            self.alertController = UIAlertController(title: nil, message: err.msg, preferredStyle: .alert)
                            self.present(self.alertController!, animated: true, completion: {
                                self.perform(#selector(self.dismissaler), with: nil, afterDelay: 1.0)
                            })
                        }
                    }
                })
                .addDisposableTo(disposeBag)
        }
    }
    
    func dismissaler() {
        self.alertController?.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "LocationHistory" {
            if (currentDeviceData != nil) {
                let device = self.currentDeviceData?.data as? DeviceInfo
                //主要就是通过类型强转,然后通过拿到的对象进行成员变量的赋值,相对于Android,这真的是简单粗暴
                let nav2Controller = segue.destination as! LocationHistoryVC
                nav2Controller.Sprofile = device?.user?.profile
                nav2Controller.Snikename = device?.user?.nickname
                nav2Controller.deviceId = device?.deviceId
            }
        }
    }
    
    @IBAction func MobilePhoneBtnClick(_ sender: UIButton) {
        if (currentDeviceData != nil) {
            let device = currentDeviceData?.data as? DeviceInfo
            if let phone = device?.user?.number {
                let str = "telprompt://\(phone)".replacingOccurrences(of: " ", with: "")
                if let url = URL(string: str) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
        }else {
            let alertController = UIAlertController(title: "Error", message: "phone worry", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .default, handler: {
                (action : UIAlertAction!) -> Void in
                
            })
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func MobileMessageBtnClick(_ sender: UIButton) {
        
        if let chatController = R.storyboard.social.chat() {
            self.navigationController?.show(chatController, sender: nil)
        }
    }
    
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
        switch result{
            case MessageComposeResult.sent :
            print("短信已发送")
            
            case MessageComposeResult.cancelled:
            print("短信取消发送")
            
            case MessageComposeResult.failed:
            print("短信发送失败")
        }
    }
    
    @IBAction func GuideToWalk(_ sender: UIButton) {
        
        if mapView.annotations.count > 0 {
            for annotation in mapView.annotations {
                if annotation is BaseAnnotation {
                    let kidCoordinate = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
                    let options = [
                        MKLaunchOptionsDirectionsModeKey: self.curDirectionMode == .walking ? MKLaunchOptionsDirectionsModeWalking : MKLaunchOptionsDirectionsModeDriving,
                        ]
                    let placemark = MKPlacemark(coordinate: kidCoordinate, addressDictionary: nil)
                    let mapItem = MKMapItem(placemark: placemark)
                    mapItem.name = "\(self.objectNameL.text ?? "")"
                    mapItem.openInMaps(launchOptions: options)
                }
            }
            
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updateUIData(deviceInfo : DeviceInfo){
        objectNameL.text = deviceInfo.user?.nickname
        
        DeviceManager.shared.getProperty(deviceId: deviceInfo.deviceId!)
            .bindNext({
                self.electricL.text = "\($0.power ?? 0)%"
                self.signalImageV.image = UIImage(named: "home_ic_battery\(($0.power ?? 0)/20)")
            }).addDisposableTo(disposeBag)
        
        LocationManager.share.getCurrentLocation()
            .bindNext({
                self.objectLocationL.text = $0.address
                self.objectLocationTimeL.text = $0.time?.stringYearMonthDayHourMinuteSecond
        }).addDisposableTo(disposeBag)
        
    }
    
    func KidInfoToAnimation(dataSource : BasePopoverAction) {
        if dataSource.title == "ALL" {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AllKidsLocationVC") as! AllKidsLocationVC
            vc.dataArr = dataSource.data as? [DeviceInfo] ?? []
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            objectNameL.text = dataSource.title
            self.currentDeviceData = dataSource
            if let device = dataSource.data as? DeviceInfo {
                DeviceManager.shared.currentDevice = device
                
                let placeImg = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: objectImageBtn.frame.size.width, height: objectImageBtn.frame.size.height), fullName: device.user?.nickname ?? "" ).imageRepresentation()!
                
                let imgUrl = URL(string: FSManager.imageUrl(with: device.user?.profile ?? ""))
                self.objectImageBtn.kf.setBackgroundImage(with: imgUrl, for: .normal, placeholder: placeImg)
                if let power = device.property?.power {
                    electricL.text = "\(power)%"
                    signalImageV.image = UIImage(named: "home_ic_battery\(power/20)")
                }
            }
        }
    }
}

fileprivate extension UIImage {
    
    func scale(toSize: CGSize) -> UIImage? {
        
        UIGraphicsBeginImageContext(toSize)
        
        self.draw(in: CGRect.init(x: 0, y: 0, width: toSize.width, height: toSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}
extension MainMapController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is BaseAnnotation {
            let identifier = "LocationAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = ContactAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            if let device = currentDeviceData?.data as? DeviceInfo {
                (annotationView as! ContactAnnotationView).setAvatarImage(nikename: (device.user?.nickname)!, profile: (device.user?.profile)!)
            }
            annotationView?.canShowCallout = false
            return annotationView
        }
        
        return nil
    }
}
