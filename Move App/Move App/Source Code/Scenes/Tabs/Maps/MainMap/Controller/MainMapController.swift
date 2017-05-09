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

class MainMapController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet var noGeolocationView: UIView!
    @IBOutlet weak var openPreferencesBtn: UIButton!
    
    @IBOutlet weak var callOutlet: UIButton!
    @IBOutlet weak var messageOutlet: UIButton!
    @IBOutlet weak var guideOutlet: UIButton!
    
    @IBOutlet weak var nameOutle: UILabel!
    @IBOutlet weak var addressOutlet: UILabel!
    @IBOutlet weak var addressScrollLabel: ScrollLabelView!
    
    @IBOutlet weak var timeOutlet: UILabel!
    @IBOutlet weak var headPortraitOutlet: UIButton!
    
    @IBOutlet weak var statesOutlet: UIImageView!
    @IBOutlet weak var voltameterOutlet: UILabel!
    @IBOutlet weak var voltameterImageOutlet: UIImageView!

    @IBOutlet weak var remindLocationOutlet: UIButton!
    
    @IBOutlet weak var warmingView: UIView!
    
    let enterSubject = BehaviorSubject<Bool>(value: false)
    
    var isAtThisPage = Variable(false)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Location"
        self.isAtThisPage.value = true
        enterSubject.onNext(true)
        self.hidesBottomBarWhenPushed = true
        if (UserDefaults.standard.value(forKey: "address") != nil){
            self.addressScrollLabel.text = UserDefaults.standard.value(forKey: "address") as! String
            self.addressScrollLabel.scrollLabelIfNeed()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.showFeatureGudieView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isAtThisPage.value = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeOutlet.adjustsFontSizeToFitWidth = true
        
        noGeolocationView.frame = view.bounds
        view.addSubview(noGeolocationView)
        let geolocationService = GeolocationService.instance
        
        let wireframe = DefaultWireframe.sharedInstance
        
        let viewModel = MainMapViewModel(
            input: (
                enter: enterSubject.asDriver(onErrorJustReturn: false),
                avatarTap: headPortraitOutlet.rx.tap.asDriver(),
                avatarView: headPortraitOutlet,
                isAtThisPage: isAtThisPage,
                remindLocation: remindLocationOutlet.rx.tap.asObservable()
            ),
            dependency: (
                geolocationService: geolocationService,
                deviceManager: DeviceManager.shared,
                locationManager: LocationManager.share
            )
        )
        
        viewModel.allAction
            .bindNext({ [weak self] devices in
                self?.showAllKidsLocationController()
            })
            .addDisposableTo(disposeBag)
        
        viewModel.singleAction
            .map({ $0.deviceId })
            .filterNil()
            .bindTo(RxStore.shared.currentDeviceId)
            .addDisposableTo(disposeBag)
        
        viewModel.authorized
            .drive(noGeolocationView.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        openPreferencesBtn.rx.tap
            .bindNext { _ in wireframe.openSettings() }
            .addDisposableTo(disposeBag)
        
        callOutlet.rx.tap.asDriver()
            .withLatestFrom(viewModel.currentDevice)
            .map({ URL(deviceInfo: $0) })
            .filterNil()
            .drive(onNext: { wireframe.open(url: $0) })
            .addDisposableTo(disposeBag)
        
        messageOutlet.rx.tap
            .bindNext { [unowned self] in
                if let chatController = R.storyboard.social.chat() {
                    self.navigationController?.show(chatController, sender: nil)
                }
            }
            .addDisposableTo(disposeBag)
        
        let name = viewModel.currentDevice.map { $0.user?.nickname }.filterNil()
        name.drive(nameOutle.rx.text).addDisposableTo(disposeBag)
        
        let nameAndLocation = Observable.combineLatest(name.asObservable(), viewModel.kidLocation)
        guideOutlet.rx.tap.asObservable()
            .withLatestFrom(nameAndLocation)
            .bindNext { MapUtility.openPlacemark(name: $0.0, location: $0.1) }
            .addDisposableTo(disposeBag)
        
        viewModel.fetchDevices.drive(viewModel.devicesVariable).addDisposableTo(disposeBag)
        
        viewModel.currentDevice
            .drive(onNext: { [weak self] in
                self?.showHeadPortrait(deviceInfo: $0)
                self?.showVoltameterOutlet(deviceInfo: $0)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.currentProperty
            .withLatestFrom(viewModel.currentDevice) { (property, info) in DeviceInfo(property: property, info: info) }
            .withLatestFrom(viewModel.devicesVariable.asObservable()) { (info, infos) in transform(info: info, infos: infos) }
            .bindTo(viewModel.devicesVariable)
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
        
        Observable.combineLatest(viewModel.kidType.map({ $0.description }), viewModel.kidAddress) { "\($1)" }
            .subscribe(onNext: { textI in
                self.autoRolling(a: textI)
            })
            .addDisposableTo(disposeBag)
        
        
        
        viewModel.locationTime
            .map({ $0.stringYearMonthDayHourMinuteSecond })
            .bindTo(timeOutlet.rx.text)
            .addDisposableTo(disposeBag)
        
        viewModel.kidLocation
            .distinctUntilChanged { $0.latitude == $1.latitude && $0.longitude == $1.longitude }
            .bindNext({ [unowned self] in
                let region = MKCoordinateRegionMakeWithDistance($0, 500, 500)
                self.mapView.setRegion(region, animated: true)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.kidAnnotion
            .distinctUntilChanged()
            .bindNext({ [unowned self] annotion in
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotation(annotion)
            })
            .addDisposableTo(disposeBag)
        
        mapView.rx.regionDidChangeAnimated.asObservable()
            .bindNext { [unowned self] (_) in
                self.redrawRadius()
            }
            .addDisposableTo(disposeBag)
        
        viewModel.remindSuccess.debug()
            .bindTo(warmingView.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        let realm = try! Realm()
        let userID = RxStore.shared.uidObservable
        let devUID = viewModel.currentDevice.map{ $0.user?.uid }.filterNil().asObservable()
        Observable.combineLatest(userID, devUID) { ($0, $1) }
            .flatMapLatest { (uid, devuid) -> Observable<Int> in
                guard let groups = realm.objects(SynckeyEntity.self).filter("uid == %@", uid).first?.groups,
                    let group = groups.filter({ $0.members.contains(where: { $0.id == devuid }) }).first else {
                    return Observable.empty()
                }
                return Observable.collection(from: group.messages).map{ $0.filter("readStatus == 0").count }
            }
            .bindTo(messageOutlet.rx.badgeCount)
            .addDisposableTo(disposeBag)
        
        AlertServer.share.navigateLocationSubject
            .bindNext { [weak self] in self?.showNavigationSheetView(locationInfo: $0) }
            .addDisposableTo(disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = R.segue.mainMapController.locationHistory(segue: segue)?.destination {
            if let device = DeviceManager.shared.currentDevice {
                vc.Sprofile = device.user?.profile
                vc.Snikename = device.user?.nickname
                vc.deviceId = device.deviceId
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func autoRolling(a: String = "Loading") {
        self.addressScrollLabel.addObaserverNotification()
        self.addressScrollLabel.text = a
        UserDefaults.standard.set(a, forKey: "address")
    }
}


extension MainMapController {
    
    fileprivate func showFeatureGudieView() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let headItem = EAFeatureItem(focus: headPortraitOutlet,
                                         focusCornerRadius: headPortraitOutlet.frame.width/2 ,
                                         focus: UIEdgeInsets.zero)
            headItem?.actionTitle = "I Know"
            headItem?.introduce = "Tap here to change watch"
            headItem?.action = { _ in
                let navItem = EAFeatureItem(focus: self.addressOutlet,
                                            focusCornerRadius: 6 ,
                                            focus: UIEdgeInsets.zero)
                navItem?.actionTitle = "I Know"
                navItem?.introduce = "Tap here to navigate"
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0, execute: {
                    self.view.show(with: [navItem!], saveKeyName: "mark:main_map:nav", inVersion: version)
                })
            }
            self.view.show(with: [headItem!], saveKeyName: "mark:main_map:head", inVersion: version)
        }
    }
    
    fileprivate func showNavigationSheetView(locationInfo: KidSate.LocationInfo) {
        
        let sheetView = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        sheetView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let name = locationInfo.address, let location = locationInfo.location {
            sheetView.addAction(UIAlertAction(title: "Navigation", style: .default) { _ in
                MapUtility.openPlacemark(name: name, location: location)
            })
        }
        
        self.present(sheetView, animated: true, completion: nil)
    }
    
    fileprivate func showAllKidsLocationController() {
        self.performSegue(withIdentifier: R.segue.mainMapController.showAllKidsLocation, sender: nil)
    }
    
    fileprivate func showVoltameterOutlet(deviceInfo: DeviceInfo) {
        if let power = deviceInfo.property?.power {
            voltameterOutlet.text = "\(power)%"
            voltameterImageOutlet.image = UIImage(named: "home_ic_battery\(power/20)")
        }
    }

    fileprivate func showHeadPortrait(deviceInfo: DeviceInfo) {
        let placeImg = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0,
                                                      width: headPortraitOutlet.frame.size.width,
                                                      height: headPortraitOutlet.frame.size.height),
                                         fullName: deviceInfo.user?.nickname ?? "" )
            .imageRepresentation()!
        
        let imgUrl = deviceInfo.user?.profile?.fsImageUrl.url
        self.headPortraitOutlet.kf.setBackgroundImage(with: imgUrl, for: .normal, placeholder: placeImg) { (image, _, _, _) in
            if
                let image = image,
                let online = deviceInfo.user?.online, !online {
                let effectImage = image.grayImage()
                self.headPortraitOutlet.setBackgroundImage(effectImage, for: .normal)
            }
        }
        self.dotDot(online: deviceInfo.user?.online ?? true)
    }
}


extension MainMapController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? AccuracyAnnotation {
            let identifier = "mainMapAccuracyAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? PulsingAnnotationView
            if annotationView == nil {
                annotationView = PulsingAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.radius = convert(mapView, radius: annotation.accuracy).width
            }
            annotationView?.canShowCallout = false
            return annotationView
        }
        return nil
    }
    
    fileprivate var mainAnnotationView: PulsingAnnotationView? {
        guard let annotation = self.mapView.annotations.first else {
            return nil
        }
        return self.mapView.view(for: annotation) as? PulsingAnnotationView
    }
    
    fileprivate func redrawRadius() {
        guard let annotation = self.mapView.annotations.first as? AccuracyAnnotation else {
            return
        }
        self.mainAnnotationView?.radius = convert(self.mapView, radius: annotation.accuracy).width
    }
    
    func dotDot(online: Bool) {
        self.mainAnnotationView?.dotColorDot = online ? defaultDotColor : UIColor.gray
    }
}


extension MainMapController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
        switch result{
        case .sent :
            Logger.debug("短信已发送")
        case .cancelled:
            Logger.debug("短信取消发送")
        case .failed:
            Logger.debug("短信发送失败")
        }
    }
}


fileprivate func convert(_ mapView: MKMapView, radius: CLLocationDistance) -> CGRect {
    let region = MKCoordinateRegionMakeWithDistance(mapView.centerCoordinate, radius, radius)
    return mapView.convertRegion(region, toRectTo: mapView)
}


fileprivate func transform(info: DeviceInfo, infos: [DeviceInfo]) -> [DeviceInfo] {
    var devices = infos
    if let index = infos.index(where: { $0.deviceId == info.deviceId }) {
        devices[index] = info
    }
    return devices
}

fileprivate extension DeviceInfo {

    init(property: DeviceProperty, info: DeviceInfo) {
        self.init()
        self = info
        self.property = property
    }
}

extension String {
    var url: URL? {
        return URL(string: self)
    }
}

extension URL {
    init?(deviceInfo: DeviceInfo) {
        guard let number = deviceInfo.user?.number else {
            return nil
        }
        let phone = "telprompt://\(number)".replacingOccurrences(of: " ", with: "")
        self.init(string: phone)
    }
}

extension UIImage {
    
    func grayImage() -> UIImage {
        let imageRef = self.cgImage!
        let width = imageRef.width
        let height = imageRef.height
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context.draw(imageRef, in: rect)
        let outPutImage = context.makeImage()!
        let newImage = UIImage(cgImage: outPutImage, scale: self.scale, orientation: self.imageOrientation)
        return newImage
    }
    
}
