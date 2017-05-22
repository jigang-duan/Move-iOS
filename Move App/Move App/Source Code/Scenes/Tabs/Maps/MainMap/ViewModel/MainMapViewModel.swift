//
//  MainMapViewModel.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import MapKit
import RxOptional


class MainMapViewModel {
    // outputs {
    
    let authorized: Driver<Bool>
    
    let kidLocation: Observable<CLLocationCoordinate2D>
    let kidAddress: Observable<String>
    let kidType: Observable<KidSate.LocationType>
    let locationTime: Observable<Date>
    
    let kidAnnotion: Observable<AccuracyAnnotation>
    
    let singleAction: Observable<DeviceInfo>
    let allAction: Observable<[DeviceInfo]>
    
    let activityIn: Driver<Bool>
    
    let devicesVariable: Variable<[DeviceInfo]>
    let currentDevice: Driver<DeviceInfo>
    
    let currentProperty: Observable<DeviceProperty>
    
    let fetchDevices: Driver<[DeviceInfo]>
    
    let remindSuccess: Observable<Bool>
    let remindActivityIn: Driver<Bool>
    
    let errorObservable: Observable<Error>
    
    let badgeCount: Observable<Int>
    
    let lowBattery: Observable<Int>
    
    init(
        input: (
            enter: Driver<Bool>,
            avatarTap: Driver<Void>,
            avatarView: UIView,
            isAtThisPage: Variable<Bool>,
            remindLocation: Observable<Void>
        ),
         dependency: (
            geolocationService: GeolocationService,
            deviceManager: DeviceManager,
            locationManager: LocationManager
        )
        ) {
        
        authorized = dependency.geolocationService.authorized
        let _ = dependency.geolocationService.location
        let deviceManager = dependency.deviceManager
        let locationManager = dependency.locationManager
        
        let activitying = ActivityIndicator()
        self.activityIn = activitying.asDriver()
        
        let currentDeviceId = RxStore.shared.currentDeviceId.asDriver()
        devicesVariable = RxStore.shared.deviceInfosState

        currentDevice = Driver.combineLatest(
            devicesVariable.asDriver(),
            currentDeviceId.filterNil()
        ) { (devices, id) in devices.filter({$0.deviceId == id}).first }
            .filterNil()
        
        let enter = input.enter.filter {$0}.map{ _ in Void() }
        
        fetchDevices = enter
            .flatMapLatest {
                deviceManager.fetchDevices().asDriver(onErrorJustReturn: [])
            }
        
        let period = Observable<Int>.timer(2,
                                           period: Configure.App.LoadDataOfPeriod,
                                           scheduler: MainScheduler.instance)
            .withLatestFrom(input.isAtThisPage.asObservable())
            .filter({ $0 })
            .map({ _ in Void() })
            .shareReplay(1)
        
        let remindActivitying = PublishSubject<Bool>()
        self.remindActivityIn = remindActivitying.asDriver(onErrorJustReturn: false)
        
        let errorSubject = PublishSubject<Error>()
        
        let enterForeground = NotificationCenter.default.rx.notification(.UIApplicationWillEnterForeground).map{_ in Void() }
        remindSuccess = Observable.merge(enterForeground, input.remindLocation)
            .startWith(())
            .throttle(1.0, scheduler: MainScheduler.instance)
            .withLatestFrom(currentDeviceId.asObservable().filterNil())
            .do(onNext: { _ in remindActivitying.onNext(true) })
            .flatMapLatest {
                deviceManager.remindLocation(deviceId: $0)
                    .do(onError: { errorSubject.onNext($0) })
                    .catchErrorJustReturn(false)
            }
            .share()
        
        let remindLocation = remindSuccess
            .flatMapLatest { _ in MessageServer.share.manuallyLocate }
        
        let remindTimeOut = remindSuccess.delay(60.0, scheduler: MainScheduler.instance)
            .withLatestFrom(remindActivitying.asObserver())
            .filter { $0 }
            .map{ _ in WorkerError.LocationTimeout as Error }
            .do(onNext: { _ in remindActivitying.onNext(false) })
        
        errorObservable = Observable.merge(errorSubject.asObserver(), remindTimeOut)
        
        let currentLocation = Observable.merge(period, remindLocation)
            .flatMapLatest {
                locationManager.currentLocation
                    .trackActivity(activitying)
                    .catchErrorJustReturn(KidSate.LocationInfo())
            }
            .shareReplay(1)
        
        currentProperty = period
            .withLatestFrom(currentDeviceId.asObservable())
            .filterNil()
            .flatMapLatest {
                deviceManager.getProperty(deviceId: $0)
                    .trackActivity(activitying)
                    .catchErrorJustReturn(DeviceProperty())
            }
            .shareReplay(1)
        
        kidLocation = currentLocation.map{ $0.location }.filterNil()
            .distinctUntilChanged { $0.latitude == $1.latitude && $0.longitude == $1.longitude }
            .do(onNext: { _ in remindActivitying.onNext(false) })
        
        kidAddress = currentLocation.map{ $0.address }.filterNil()
        kidType = currentLocation.map{ $0.type }.filterNil()
        locationTime = currentLocation.map{ $0.time }.filterNil()
        
        let accuracy = currentLocation.map { $0.accuracy }.filterNil()
        kidAnnotion = Observable.combineLatest(kidLocation, accuracy) { AccuracyAnnotation($0, accuracy: $1) }
        
        let kidInfos = input.avatarTap
            .withLatestFrom(devicesVariable.asDriver())
        
        let popoer = RxPopover.shared
        popoer.style = .dark
        let selecedAction = kidInfos.asObservable()
            .map(allAndTransformAction)
            .flatMapLatest({ actions in popoer.promptFor(toView: input.avatarView, actions: actions) })
            .shareReplay(1)
        
        allAction = selecedAction.map({ $0.data as? [DeviceInfo] }).filterNil()
        singleAction = selecedAction.map({ $0.data as? DeviceInfo  }).filterNil()
        
        let userID = RxStore.shared.uidObservable
        let devUID = currentDevice.map{ $0.user?.uid }.filterNil().asObservable()
        badgeCount = Observable.combineLatest(userID, devUID) { ($0, $1) }
            .flatMapLatest { IMManager.shared.countUnreadMessages(uid: $0, devUid: $1) }
        
        lowBattery = MessageServer.share.lowBattery
            .flatMapLatest{ deviceManager.power.catchErrorJustReturn(0) }
        
        
    }
}

fileprivate func transformAction(infos: [DeviceInfo]) -> [BasePopoverAction] {
    return infos.map { BasePopoverAction(info: $0) }
}

fileprivate func allAndTransformAction(infos: [DeviceInfo]) -> [BasePopoverAction] {
    return [BasePopoverAction(infos: infos)] + transformAction(infos: infos)
}

extension BasePopoverAction {
    
    convenience init(info: DeviceInfo) {
        self.init(imageUrl: info.user?.profile?.fsImageUrl,
                  placeholderImage: R.image.home_pop_all(),
                  title: info.user?.nickname,
                  isSelected: true,
                  handler: nil)
        self.canAvatar = true
        self.data = info
    }
    
    convenience init(infos: [DeviceInfo]) {
        self.init(imageUrl: nil,
                  placeholderImage: R.image.home_pop_all(),
                  title: R.string.localizable.id_all(),
                  isSelected: true,
                  handler: nil)
        self.data = infos
    }
    
}
