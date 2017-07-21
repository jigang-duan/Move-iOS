//
//  MainMap+Controller+Binding.swift
//  Move App
//
//  Created by jiang.duan on 2017/7/18.
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

extension MainMapController {

    override func initBinding() {
        
        let wireframe = DefaultWireframe.sharedInstance
        
        let viewModel = MainMapViewModel(
            input: (
                enter: enterSubject.asDriver(onErrorJustReturn: ()),
                avatarTap: headPortraitOutlet.rx.tap.asDriver(),
                callTap: callOutlet.rx.tap.asDriver(),
                offTrackingModeTap: offTrackingModeOutlet.rx.tap.asDriver(),
                avatarView: headPortraitOutlet,
                isAtThisPage: isAtThisPage,
                remindLocation: remindLocationOutlet.rx.tap.asObservable()
            ),
            dependency: (
                geolocationService: GeolocationService.instance,
                reachabilityService: NetworkReachabilityService.instance,
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
        
        viewModel.authorized.drive(noGeolocationView.rx.isHidden).addDisposableTo(disposeBag)
        
        viewModel.callTelprompt.drive(onNext: { wireframe.open(url: $0) }).addDisposableTo(disposeBag)
        
        let name = viewModel.currentDevice.map { $0.user?.nickname }.filterNil()
        name.drive(nameOutle.rx.text).addDisposableTo(disposeBag)
        
        let nameAndLocation = Observable.combineLatest(name.asObservable(), viewModel.kidLocation)
        
        Observable.merge(guideOutlet.rx.tap.asObservable(), tapAddressOutlet.rx.event.asObservable().mapVoid())
            .withLatestFrom(nameAndLocation)
            .bindNext { MapUtility.openPlacemark(name: $0.0, location: $0.1) }
            .addDisposableTo(disposeBag)
        
        viewModel.fetchDevices.drive(viewModel.devicesVariable).addDisposableTo(disposeBag)
        
        let portrait = viewModel.currentDevice.map{ try? $0.user?.profile?.fsImageUrl.asURL() }.filterNil()
        Driver.combineLatest(portrait, name) { ($0, $1) }
            .drive(headPortraitOutlet.rx.initialsAvatar)
            .addDisposableTo(disposeBag)
        
        viewModel.online.map { $0 ? R.image.home_ic_wear() : R.image.home_ic_nottowear() }.drive(statesOutlet.rx.image).addDisposableTo(disposeBag)
        viewModel.online.map{ !$0 }.drive(voltameterOutlet.rx.isHidden).addDisposableTo(disposeBag)
        viewModel.online.map{ !$0 }.drive(voltameterImageOutlet.rx.isHidden).addDisposableTo(disposeBag)
        viewModel.online.drive(remindLocationOutlet.rx.isEnabled).addDisposableTo(disposeBag)
        viewModel.online.drive(mapView.rx.online).addDisposableTo(disposeBag)
        
        viewModel.power.map{ "\($0)%" }.drive(voltameterOutlet.rx.text).addDisposableTo(disposeBag)
        viewModel.power.map{ UIImage(named: "home_ic_battery\($0/20)") }.drive(voltameterImageOutlet.rx.image).addDisposableTo(disposeBag)
        
        viewModel.currentProperty
            .withLatestFrom(viewModel.currentDevice) { (property, info) in DeviceInfo(property: property, info: info) }
            .withLatestFrom(viewModel.devicesVariable.asObservable()) { (info, infos) in transform(info: info, infos: infos) }
            .bindTo(viewModel.devicesVariable)
            .addDisposableTo(disposeBag)
        
        viewModel.kidAddress.bindTo(addressScrollLabel.rx.text).addDisposableTo(disposeBag)
        viewModel.locationTime.map { $0.stringScreenDescription }.bindTo(timeOutlet.rx.text).addDisposableTo(disposeBag)
        viewModel.kidLocation.map{ MKCoordinateRegionMakeWithDistance($0, 500, 500) }.bindTo(mapView.rx.region).addDisposableTo(disposeBag)
        viewModel.kidAnnotion.distinctUntilChanged().bindTo(mapView.rx.soleAccuracyAnnotation).addDisposableTo(disposeBag)
        
        mapView.rx.regionDidChangeAnimated.asObservable().mapVoid()
            .bindTo(mapView.rx.redrawRadius)
            .addDisposableTo(disposeBag)
        
        viewModel.remindActivityIn.drive(remindActivityOutlet.rx.isAnimating).addDisposableTo(disposeBag)
        viewModel.remindActivityIn.map{ !$0 }.drive(remindActivityOutlet.rx.isHidden).addDisposableTo(disposeBag)
        viewModel.remindActivityIn.drive(remindLocationOutlet.rx.isHidden).addDisposableTo(disposeBag)
        
        viewModel.errorObservable
            .map { WorkerError.timeoutAndApiErrorTransform(from: $0) }
            .filterEmpty()
            .bindNext { ProgressHUD.show(status: $0) }
            .addDisposableTo(disposeBag)
        
        viewModel.badgeCount.bindTo(messageOutlet.rx.badgeCount).addDisposableTo(disposeBag)
        
        AlertServer.share.navigateLocationSubject.bindTo(rx.navigationSheet).addDisposableTo(disposeBag)
        
        viewModel.hasNotication
            .map { $0 ? R.image.nav_notice_new()!.withRenderingMode(.alwaysOriginal) : R.image.nav_notice_nor()! }
            .bindTo(noticeOutlet.rx.image)
            .addDisposableTo(disposeBag)
        
        let netNoReachable = viewModel.netReachable.map{ !$0 }.asDriver(onErrorJustReturn: false)
        Driver.combineLatest(viewModel.online, viewModel.autoPosistion, netNoReachable) { $2 || (!$2 && (!$0 || ($0 && !$1))) }
            .drive(trackingModeOutlet.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        Driver.combineLatest(viewModel.online, netNoReachable) { $0 && !$1 }
            .drive(offlineModeOutlet.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        netNoReachable.map{ $0 ? "Network disconnected. Check network." : "Watch offine,please check the watch's network."  }
            .drive(offlineTitleOutlet.rx.text)
            .addDisposableTo(disposeBag)
        
        Driver.combineLatest(viewModel.online, viewModel.autoPosistion, netNoReachable) {!$0 || $1 || $2}
            .map{ $0 ? 54.0 : 15.0 }
            .drive(floatMenuTopConstraint.rx.constant)
            .addDisposableTo(disposeBag)
        
        viewModel.activityIn.drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible).addDisposableTo(disposeBag)
    }

}

fileprivate func transform(info: DeviceInfo, infos: [DeviceInfo]) -> [DeviceInfo] {
    var devices = infos
    if let index = infos.index(where: { $0.deviceId == info.deviceId }) {
        devices[index] = info
    }
    return devices
}

