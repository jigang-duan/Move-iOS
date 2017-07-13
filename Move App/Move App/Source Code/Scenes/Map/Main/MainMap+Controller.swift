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
    
    @IBOutlet weak var remindActivityOutlet: ActivityImageView!
    
    @IBOutlet weak var noticeOutlet: UIBarButtonItem!
    
    @IBOutlet weak var trackingModeOutlet: UIView!
    @IBOutlet weak var offTrackingModeOutlet: UIButton!
    @IBOutlet weak var offlineModeOutlet: UIView!
    
    @IBOutlet var tapAddressOutlet: UITapGestureRecognizer!
    @IBOutlet weak var floatMenuTopConstraint: NSLayoutConstraint!
    
    let enterSubject = PublishSubject<Void>()
    
    var isAtThisPage = Variable(false)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.isAtThisPage.value = true
        enterSubject.onNext(())

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.showFeatureGudieView()
        self.addressScrollLabel.scrollLabelIfNeed()
        
        propelToTargetController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isAtThisPage.value = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeOutlet.adjustsFontSizeToFitWidth = true
        
        self.addressScrollLabel.addObaserverNotification()
        addressScrollLabel.textFont = UIFont.systemFont(ofSize: 15.0)
        addressScrollLabel.textColor = R.color.appColor.secondayText()
        
        self.navigationItem.title = R.string.localizable.id_top_menu_location()
        self.navigationController?.tabBarController?.tabBarItem.title = R.string.localizable.id_button_menu_home()
        callOutlet.setTitle(R.string.localizable.id_location_call(), for: .normal)
        messageOutlet.setTitle(R.string.localizable.id_location_message(), for: .normal)
        
        noGeolocationView.frame = view.bounds
        view.addSubview(noGeolocationView)
        let geolocationService = GeolocationService.instance
        
        let wireframe = DefaultWireframe.sharedInstance
        
        let viewModel = MainMapViewModel(
            input: (
                enter: enterSubject.asDriver(onErrorJustReturn: ()),
                avatarTap: headPortraitOutlet.rx.tap.asDriver(),
                offTrackingModeTap: offTrackingModeOutlet.rx.tap.asDriver(),
                avatarView: headPortraitOutlet,
                isAtThisPage: isAtThisPage,
                remindLocation: remindLocationOutlet.rx.tap.asObservable()
            ),
            dependency: (
                geolocationService: geolocationService,
                deviceManager: DeviceManager.shared,
                settingsManager: WatchSettingsManager.share,
                locationManager: LocationManager.share,
                wireframe: AlertWireframe.shared
            )
        )
        
        viewModel.allAction.mapVoid().bindTo(rx.segueAllKids).addDisposableTo(disposeBag)
        
        viewModel.singleAction
            .map{ $0.deviceId }
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
            .map{ URL(deviceInfo: $0) }
            .filterNil()
            .drive(onNext: { wireframe.open(url: $0) })
            .addDisposableTo(disposeBag)
        
        messageOutlet.rx.tap.asObservable().bindTo(rx.segueChat).addDisposableTo(disposeBag)
        
        let name = viewModel.currentDevice.map { $0.user?.nickname }.filterNil()
        name.drive(nameOutle.rx.text).addDisposableTo(disposeBag)
        
        let nameAndLocation = Observable.combineLatest(name.asObservable(), viewModel.kidLocation)
        
        Observable.merge(guideOutlet.rx.tap.asObservable(), tapAddressOutlet.rx.event.asObservable().map{_ in () })
            .withLatestFrom(nameAndLocation)
            .bindNext { MapUtility.openPlacemark(name: $0.0, location: $0.1) }
            .addDisposableTo(disposeBag)
        
        viewModel.fetchDevices.drive(viewModel.devicesVariable).addDisposableTo(disposeBag)
        
        let portrait = viewModel.currentDevice.map{ try? $0.user?.profile?.fsImageUrl.asURL() }.filterNil()
        Driver.combineLatest(portrait, name) { ($0, $1) }
            .drive(headPortraitOutlet.rx.initialsAvatar)
            .addDisposableTo(disposeBag)
        
        viewModel.online.map { $0 ? R.image.home_ic_wear() : R.image.home_ic_nottowear() }
            .drive(statesOutlet.rx.image)
            .addDisposableTo(disposeBag)
        
        viewModel.online.map{ !$0 }.drive(voltameterOutlet.rx.isHidden).addDisposableTo(disposeBag)
        viewModel.online.map{ !$0 }.drive(voltameterImageOutlet.rx.isHidden).addDisposableTo(disposeBag)
        
        let power = Driver.merge(
            viewModel.currentDevice.map{ $0.property?.power }.filterNil(),
            viewModel.battery.asDriver(onErrorJustReturn: 0)
        )
        power.map{ "\($0)%" }.drive(voltameterOutlet.rx.text).addDisposableTo(disposeBag)
        power.map{ UIImage(named: "home_ic_battery\($0/20)") }.drive(voltameterImageOutlet.rx.image).addDisposableTo(disposeBag)
        
        viewModel.currentProperty
            .withLatestFrom(viewModel.currentDevice) { (property, info) in DeviceInfo(property: property, info: info) }
            .withLatestFrom(viewModel.devicesVariable.asObservable()) { (info, infos) in transform(info: info, infos: infos) }
            .bindTo(viewModel.devicesVariable)
            .addDisposableTo(disposeBag)
        
        mapView.rx.willStartLoadingMap.asDriver()
            .drive(onNext: { Logger.debug("地图开始加载!") })
            .addDisposableTo(disposeBag)
        
        mapView.rx.didFinishLoadingMap.asDriver()
            .drive(onNext: { Logger.debug("地图结束加载!") })
            .addDisposableTo(disposeBag)
        
        mapView.rx.didAddAnnotationViews.asDriver()
            .drive(onNext: { Logger.debug("地图Annotion个数: \($0.count)")})
            .addDisposableTo(disposeBag)
        
        viewModel.kidAddress
            .bindTo(addressScrollLabel.rx.text)
            .addDisposableTo(disposeBag)
        
        
        viewModel.locationTime
            .map { $0.stringScreenDescription }
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
        
        mapView.rx.regionDidChangeAnimated.asObservable().mapVoid()
            .bindTo(mapView.rx.redrawRadius)
            .addDisposableTo(disposeBag)
        
        viewModel.remindActivityIn.drive(remindActivityOutlet.rx.isAnimating).addDisposableTo(disposeBag)
        viewModel.remindActivityIn.map{ !$0 }.drive(remindActivityOutlet.rx.isHidden).addDisposableTo(disposeBag)
        viewModel.remindActivityIn.drive(remindLocationOutlet.rx.isHidden).addDisposableTo(disposeBag)
        viewModel.online.drive(remindLocationOutlet.rx.isEnabled).addDisposableTo(disposeBag)
        
        viewModel.errorObservable
            .map { WorkerError.timeoutAndApiErrorTransform(from: $0) }
            .filterEmpty()
            .bindNext { ProgressHUD.show(status: $0) }
            .addDisposableTo(disposeBag)
        
        viewModel.badgeCount.bindTo(messageOutlet.rx.badgeCount).addDisposableTo(disposeBag)
        
        AlertServer.share.navigateLocationSubject.bindTo(rx.navigationSheet).addDisposableTo(disposeBag)
        
        let realm = try! Realm()
        let gidsObservable = RxStore.shared.deviceInfosObservable.filterEmpty().map{ $0.flatMap{ $0.user?.gid } }
        RxStore.shared.uidObservable
            .flatMapLatest { (uid) -> Observable<Bool> in
                let notices = realm.objects(NoticeEntity.self).filter("to == %@", uid)
                return Observable.collection(from: notices)
                    .map{ $0.filter("readStatus == 0") }
                    .map{ $0.filter{ $0.imType.atNotiicationPage } }
                    .withLatestFrom(gidsObservable, resultSelector: resultSelector)
                    .map{ $0.count > 0 }
            }
            .map { $0 ? R.image.nav_notice_new()!.withRenderingMode(.alwaysOriginal) : R.image.nav_notice_nor()! }
            .bindTo(noticeOutlet.rx.image)
            .addDisposableTo(disposeBag)
        
        Driver.combineLatest(viewModel.online, viewModel.autoPosistion) { $0 ? !$1 : true }
            .drive(trackingModeOutlet.rx.isHidden)
            .addDisposableTo(disposeBag)
        viewModel.online.drive(offlineModeOutlet.rx.isHidden).addDisposableTo(disposeBag)
        
        Driver.combineLatest(viewModel.online, viewModel.autoPosistion) { !$0 || $1 }
            .map{ $0 ? 54.0 : 15.0 }
            .drive(floatMenuTopConstraint.rx.constant)
            .addDisposableTo(disposeBag)
        
        viewModel.online.drive(mapView.rx.online).addDisposableTo(disposeBag)
        
        viewModel.activityIn.drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible).addDisposableTo(disposeBag)
        
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
}


fileprivate func transform(info: DeviceInfo, infos: [DeviceInfo]) -> [DeviceInfo] {
    var devices = infos
    if let index = infos.index(where: { $0.deviceId == info.deviceId }) {
        devices[index] = info
    }
    return devices
}

fileprivate func resultSelector(notices: [NoticeEntity], gids: [String]) throws -> [NoticeEntity] {
    return notices.filter{  gids.contains($0.groupId ?? "") }
}

