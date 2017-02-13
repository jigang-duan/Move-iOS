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


class MainMapViewModel {
    // outputs {
    
    let authorized: Driver<Bool>
    let userLocation: Driver<CLLocationCoordinate2D>
    
    let kidLocation: Driver<CLLocationCoordinate2D>
    let kidAnnotion: Driver<BaseAnnotation>
    
    // }
    
    init(input: (),
         dependency: (
            geolocationService: GeolocationService,
            kidInfo: MokKidInfo
        )
        ) {
        
        authorized = dependency.geolocationService.authorized
        userLocation = dependency.geolocationService.location
        
        kidLocation = Observable<Int>.timer(30, period: Configure.App.LoadDataOfPeriod, scheduler: SerialDispatchQueueScheduler(qos: .background))
            .flatMapLatest { Observable.just(CLLocationCoordinate2DMake(23.227465 + Double($0) * 0.0002, 113.190765)) }
            .asDriver(onErrorRecover: { _ in dependency.geolocationService.location } )
        
        kidAnnotion = kidLocation
            .map { BaseAnnotation($0) }
        
    }
}


class MokKidInfo {
}
