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
    //let userLocation: Driver<CLLocationCoordinate2D>
    
    let kidLocation: Observable<CLLocationCoordinate2D>
    let kidAnnotion: Observable<BaseAnnotation>
    
    //let kidInfos: Driver<[MoveApi.DeviceInfo]>
    let selecedAction: Observable<BasePopoverAction>
    
    let activityIn: Driver<Bool>
    
    let deviceInfos: Driver<[DeviceInfo]>
    
    init(
        input: (
            enterCount: Driver<Int>,
            avatarTap: Driver<Void>,
            avatarView: UIView,
            isAtThisPage: Driver<Bool>
        ),
         dependency: (
            geolocationService: GeolocationService,
            deviceManager: DeviceManager,
            locationManager: LocationManager
        )
        ) {
        
        authorized = dependency.geolocationService.authorized
        let userLocation = dependency.geolocationService.location
        let deviceManager = dependency.deviceManager
        let locationManager = dependency.locationManager
        
        let activitying = ActivityIndicator()
        self.activityIn = activitying.asDriver()
        
        
        let enter = input.enterCount.filter {$0 > 0}
        
        deviceInfos = enter.flatMapLatest({ _ in
            return deviceManager.fetchDevices().asDriver(onErrorJustReturn: [])
        })
        
        kidLocation = Observable<Int>.timer(2, period: Configure.App.LoadDataOfPeriod, scheduler: MainScheduler.instance)
            .flatMapFirst({  _ in input.isAtThisPage    })
            .filter({  $0  })
            .flatMapLatest ({_ in
                locationManager.getCurrentLocation()
                    .trackActivity(activitying)
                    .map({  $0.location })
                    .filterNil()
                    .catchError({ _ -> Observable<CLLocationCoordinate2D> in
                        userLocation.asObservable().take(1)
                    })
            })
        
        kidAnnotion = kidLocation
            .map { BaseAnnotation($0) }
        
        let kidInfos = input.avatarTap
            .flatMapLatest({
                deviceManager.fetchDevices()
                    .trackActivity(activitying)
                    .asDriver(onErrorJustReturn: [])
            })
        
        let popoer = RxPopover.shared
        
        popoer.style = .dark
        
        selecedAction = kidInfos.asObservable()
            .map(allAndTransformAction)
            .flatMapLatest({ actions in
                return popoer.promptFor(toView: input.avatarView, actions: actions)
            })
    }
}

fileprivate func transformAction(infos: [DeviceInfo]) -> [BasePopoverAction] {
    
    return infos.map({
            let action = BasePopoverAction(imageUrl: $0.user?.profile,
                                               placeholderImage: R.image.home_pop_all(),
                                               title: $0.user?.nickname,
                                               isSelected: true,
                                               handler: nil)
            action.canAvatar = true
            action.data = $0
            return action
        })
}

fileprivate func allAndTransformAction(infos: [DeviceInfo]) -> [BasePopoverAction] {
    let allAction = BasePopoverAction(imageUrl: nil,
                                      placeholderImage: R.image.home_pop_all(),
                                      title: "ALL",
                                      isSelected: false,
                                      handler: nil)
    allAction.data = infos
    return [allAction] + transformAction(infos: infos)
}



