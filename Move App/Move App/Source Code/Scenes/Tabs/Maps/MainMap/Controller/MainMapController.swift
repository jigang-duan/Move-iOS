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
    @IBOutlet weak var addressScrollLabel: ScrollLabelView!
    
    @IBOutlet weak var timeOutlet: UILabel!
    @IBOutlet weak var headPortraitOutlet: UIButton!
    
    @IBOutlet weak var statesOutlet: UIImageView!
    @IBOutlet weak var voltameterOutlet: UILabel!
    @IBOutlet weak var voltameterImageOutlet: UIImageView!

    @IBOutlet weak var remindLocationOutlet: UIButton!
    
    @IBOutlet weak var remindActivityOutlet: UIActivityIndicatorView!
    
    let enterSubject = BehaviorSubject<Bool>(value: false)
    
    var isAtThisPage = Variable(false)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Location"
        self.isAtThisPage.value = true
        enterSubject.onNext(true)
        self.hidesBottomBarWhenPushed = true

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.showFeatureGudieView()
        self.addressScrollLabel.text = address
        self.addressScrollLabel.scrollLabelIfNeed()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isAtThisPage.value = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeOutlet.adjustsFontSizeToFitWidth = true
        
        self.addressScrollLabel.addObaserverNotification()
        
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
        
        let portrait = viewModel.currentDevice.map{ try? $0.user?.profile?.fsImageUrl.asURL() }.filterNil()
        Driver.combineLatest(portrait, name) { ($0, $1) }
            .drive(headPortraitOutlet.rx.initialsAvatar)
            .addDisposableTo(disposeBag)
        
        viewModel.currentDevice.map{ $0.user?.online }.filterNil()
            .map { $0 ? R.image.home_ic_wear() : R.image.home_ic_nottowear() }
            .drive(statesOutlet.rx.image)
            .addDisposableTo(disposeBag)
        
        let power = viewModel.currentDevice.map{ $0.property?.power }.filterNil()
        power.map{ "\($0)%" }.drive(voltameterOutlet.rx.text).addDisposableTo(disposeBag)
        power.map{ UIImage(named: "home_ic_battery\($0/20)") }.drive(voltameterImageOutlet.rx.image).addDisposableTo(disposeBag)
        
        viewModel.currentProperty
            .withLatestFrom(viewModel.currentDevice) { (property, info) in DeviceInfo(property: property, info: info) }
            .withLatestFrom(viewModel.devicesVariable.asObservable()) { (info, infos) in transform(info: info, infos: infos) }
            .bindTo(viewModel.devicesVariable)
            .addDisposableTo(disposeBag)
        
        mapView.rx.willStartLoadingMap
            .asDriver()
            .drive(onNext: { Logger.debug("地图开始加载!") })
            .addDisposableTo(disposeBag)
        
        mapView.rx.didFinishLoadingMap
            .asDriver()
            .drive(onNext: { Logger.debug("地图结束加载!") })
            .addDisposableTo(disposeBag)
        
        mapView.rx.didAddAnnotationViews
            .asDriver()
            .drive(onNext: { Logger.debug("地图Annotion个数: \($0.count)")})
            .addDisposableTo(disposeBag)
        
        Observable.combineLatest(viewModel.kidType.map({ $0.description }), viewModel.kidAddress) { "\($1)" }
            .subscribe(onNext: { [unowned self] textI in
                self.autoRolling(textI)
            })
            .addDisposableTo(disposeBag)
        
        
        viewModel.locationTime
            .map { $0.stringYearMonthDayHourMinuteSecond }
            .bindTo(timeOutlet.rx.text)
            .addDisposableTo(disposeBag)
        
        viewModel.kidLocation
            .distinctUntilChanged { $0.latitude == $1.latitude && $0.longitude == $1.longitude }
            .map{ MKCoordinateRegionMakeWithDistance($0, 500, 500) }
            .bindTo(mapView.rx.region)
            .addDisposableTo(disposeBag)
        
        viewModel.kidAnnotion
            .distinctUntilChanged()
            .bindTo(mapView.rx.soleAccuracyAnnotation)
            .addDisposableTo(disposeBag)
        
        mapView.rx.regionDidChangeAnimated.asObservable()
            .bindNext { [unowned self] (_) in
                self.redrawRadius()
            }
            .addDisposableTo(disposeBag)
        
        viewModel.remindActivityIn.drive(remindActivityOutlet.rx.isAnimating).addDisposableTo(disposeBag)
        viewModel.remindActivityIn.map{ !$0 }.drive(remindActivityOutlet.rx.isHidden).addDisposableTo(disposeBag)
        viewModel.remindActivityIn.drive(remindLocationOutlet.rx.isHidden).addDisposableTo(disposeBag)
        
        viewModel.errorObservable
            .map { WorkerError.errorTransform(from: $0) }
            .bindNext { ProgressHUD.show(status: $0) }
            .addDisposableTo(disposeBag)
        
        let userID = RxStore.shared.uidObservable
        let devUID = viewModel.currentDevice.map{ $0.user?.uid }.filterNil().asObservable()
        Observable.combineLatest(userID, devUID) { ($0, $1) }
            .flatMapLatest { IMManager.shared.countUnreadMessages(uid: $0, devUid: $1) }
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
    
    
    fileprivate var address = "Loading"
}


extension MainMapController {
    
    fileprivate func autoRolling(_ text: String = "Loading") {
        self.addressScrollLabel.text = text
        address = text
    }
    
    fileprivate func showFeatureGudieView() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let headItem = EAFeatureItem(focus: headPortraitOutlet,
                                         focusCornerRadius: headPortraitOutlet.frame.width/2 ,
                                         focus: UIEdgeInsets.zero)
            headItem?.actionTitle = "I Know"
            headItem?.introduce = "Tap here to change watch"
            headItem?.action = { _ in
                let navItem = EAFeatureItem(focus: self.addressScrollLabel,
                                            focusCornerRadius: 6 ,
                                            focus: UIEdgeInsets.zero)
                navItem?.actionTitle = "I Know"
                navItem?.introduce = "Tap here to navigate"
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                    self.view.show(with: [navItem!], saveKeyName: "mark:main_map:nav", inVersion: version)
                })
            }
            self.view.show(with: [headItem!], saveKeyName: "mark:main_map:head", inVersion: version)
        }
    }
//ipad 弹框
    fileprivate func showNavigationSheetView(locationInfo: KidSate.LocationInfo) {
        let preferredStyle: UIAlertControllerStyle = UIDevice.current.userInterfaceIdiom == .phone ? .actionSheet : .alert
        let sheetView = UIAlertController(title: nil, message: nil, preferredStyle: preferredStyle)
        
        sheetView.addAction(UIAlertAction(title: R.string.localizable.id_cancel(), style: .cancel, handler: nil))
        
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

extension URL {
    init?(deviceInfo: DeviceInfo) {
        guard let number = deviceInfo.user?.number else {
            return nil
        }
        let phone = "telprompt://\(number)".replacingOccurrences(of: " ", with: "")
        self.init(string: phone)
    }
}


