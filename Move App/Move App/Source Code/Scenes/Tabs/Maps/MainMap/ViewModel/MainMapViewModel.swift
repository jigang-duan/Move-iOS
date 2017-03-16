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
    let userLocation: Driver<CLLocationCoordinate2D>
    
    let kidLocation: Driver<CLLocationCoordinate2D>
    let kidAnnotion: Driver<BaseAnnotation>
    
    //let kidInfos: Driver<[MoveApi.DeviceInfo]>
    let selecedAction: Observable<BasePopoverAction>
    
    let activityIn: Driver<Bool>
    
    // }
    
    init(input: (
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
        userLocation = dependency.geolocationService.location
        let deviceManager = dependency.deviceManager
        let locationManager = dependency.locationManager
        
        let activitying = ActivityIndicator()
        self.activityIn = activitying.asDriver()
        
        kidLocation = Driver<Int>.timer(2, period: Configure.App.LoadDataOfPeriod)
            .flatMapFirst({  _ in input.isAtThisPage    })
            .debug()
            .filter({  $0  }).debug()
            .flatMapLatest ({_ in
                locationManager.getCurrentLocation()
                    .trackActivity(activitying)
                    .map({  $0.location })
                    .filterNil()
                    .asDriver(onErrorRecover: {_ in
                        dependency.geolocationService.location
                    })
            })
        
        kidAnnotion = kidLocation
            .map { BaseAnnotation($0) }
        
        let kidInfos = input.avatarTap
            .flatMapLatest({
                deviceManager.getDeviceList()
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

fileprivate func transformAction(infos: [MoveApi.DeviceInfo]) -> [BasePopoverAction] {
    
    return infos
        .map({  let action = BasePopoverAction(imageUrl: $0.user?.profile,
                                               placeholderImage: R.image.home_pop_all(),
                                               title: $0.user?.nickname,
                                               isSelected: true,
                                               handler: nil)
            action.canAvatar = true
            action.data = $0
            return action
        })
}

fileprivate func allAndTransformAction(infos: [MoveApi.DeviceInfo]) -> [BasePopoverAction] {
    let allAction = BasePopoverAction(imageUrl: nil,
                                      placeholderImage: R.image.home_pop_all(),
                                      title: "ALL",
                                      isSelected: false,
                                      handler: nil)
    allAction.data = infos
    return [allAction] + transformAction(infos: infos)
}



