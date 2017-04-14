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
    let locationTime: Observable<Date>
    
    let kidAnnotion: Observable<BaseAnnotation>
    
    let singleAction: Observable<DeviceInfo>
    let allAction: Observable<[DeviceInfo]>
    
    let activityIn: Driver<Bool>
    
    let devicesVariable: Variable<[DeviceInfo]>
    let currentDevice: Driver<DeviceInfo>
    
    let currentProperty: Observable<DeviceProperty>
    
    let fetchDevices: Driver<[DeviceInfo]>
    
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
        
        let currentDeviceId = RxStore.shared.currentDeviceId.asDriver().debug()
        devicesVariable = RxStore.shared.deviceInfosState

        currentDevice = Driver.combineLatest(devicesVariable.asDriver().debug(), currentDeviceId.filterNil()) { (devices, id) in devices.filter({$0.deviceId == id}).first }
            .filterNil()
        
        let enter = input.enter.filter {$0}
        
        fetchDevices = enter.flatMapLatest({ _ in
                deviceManager.fetchDevices().asDriver(onErrorJustReturn: [])
            })
        
        let period = Observable<Int>.timer(2, period: Configure.App.LoadDataOfPeriod, scheduler: MainScheduler.instance)
            .withLatestFrom(input.isAtThisPage.asObservable())
            .filter({ $0 })
            .map({ _ in Void() })
            .shareReplay(1)
        
        let remindLocation = input.remindLocation
            .withLatestFrom(currentDeviceId.asObservable().filterNil())
            .flatMapLatest({
                deviceManager.remindLocation(deviceId: $0)
            })
            .catchErrorJustReturn(false)
            .map({ _ in Void() })
        
        let currentLocation = Observable.merge(period, remindLocation)
            .flatMapLatest ({
                locationManager.currentLocation
                    .trackActivity(activitying)
                    .catchErrorJustReturn(KidSate.LocationInfo())
            })
            .shareReplay(1)
        
        currentProperty = period.withLatestFrom(currentDeviceId.asObservable())
            .filterNil()
            .flatMapLatest ({
                deviceManager.getProperty(deviceId: $0)
                    .trackActivity(activitying)
                    .catchErrorJustReturn(DeviceProperty())
            })
            .shareReplay(1)
        
        kidLocation = currentLocation.map{ $0.location }.filterNil()
        kidAddress = currentLocation.map{ $0.address }.filterNil()
        locationTime = currentLocation.map{ $0.time }.filterNil()
        
        kidAnnotion = kidLocation.map { BaseAnnotation($0) }
        
        let kidInfos = input.avatarTap
            .withLatestFrom(devicesVariable.asDriver())
        
        let popoer = RxPopover.shared
        popoer.style = .dark
        let selecedAction = kidInfos.asObservable()
            .map(allAndTransformAction)
            .flatMapLatest({ actions in
                return popoer.promptFor(toView: input.avatarView, actions: actions)
            })
            .shareReplay(1)
        
        allAction = selecedAction.map({ $0.data as? [DeviceInfo] }).filterNil()
        singleAction = selecedAction.map({ $0.data as? DeviceInfo  }).filterNil()
    }
}

fileprivate func transformAction(infos: [DeviceInfo]) -> [BasePopoverAction] {
    return infos.map {BasePopoverAction(info: $0)}
}

fileprivate func allAndTransformAction(infos: [DeviceInfo]) -> [BasePopoverAction] {
    return [BasePopoverAction(infos: infos)] + transformAction(infos: infos)
}

extension BasePopoverAction {
    
    convenience init(info: DeviceInfo) {
        self.init(imageUrl: info.user?.profile,
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
                  title: R.string.localizable.all(),
                  isSelected: true,
                  handler: nil)
        self.data = infos
    }
    
}
