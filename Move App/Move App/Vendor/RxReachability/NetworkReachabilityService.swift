//
//  NetworkReachabilityService.swift
//  Move App
//
//  Created by jiang.duan on 2017/7/18.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

#if !RX_NO_MODULE
import RxSwift
#endif
import Alamofire
import Foundation

class NetworkReachabilityService
    : ReachabilityService {
    
    static let instance = NetworkReachabilityService()
    
    private let _reachabilitySubject: BehaviorSubject<ReachabilityStatus>
    
    var reachability: Observable<ReachabilityStatus> {
        return _reachabilitySubject.asObservable()
    }
    
    let _reachability: NetworkReachabilityManager?
    
    init() {
        _reachability = NetworkReachabilityManager()
        let reachabilitySubject = BehaviorSubject<ReachabilityStatus>(value: .unreachable)
        
        // so main thread isn't blocked when reachability via WiFi is checked
        let backgroundQueue = DispatchQueue(label: "reachability.wificheck")
        
        _reachability?.listener = { status in
            switch status {
            case .reachable(let connectionType):
                backgroundQueue.async {
                    reachabilitySubject.onNext(.reachable(viaWiFi: connectionType.viaWiFi))
                }
            default:
                backgroundQueue.async {
                    reachabilitySubject.onNext(.unreachable)
                }
            }
        }
        _reachability?.startListening()
        _reachabilitySubject = reachabilitySubject
    }
    
    deinit {
        _reachability?.stopListening()
    }
}

extension NetworkReachabilityManager.ConnectionType {
    
    var viaWiFi: Bool {
        switch self {
        case .ethernetOrWiFi:
            return true
        case .wwan:
            return false
        }
    }
}
