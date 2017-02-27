//
//  MeManager.swift
//  Move App
//
//  Created by jiang.duan on 2017/2/23.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift

/// User Me Protocl
protocol MeWorkerProtocl {
}


class MeManager {
    static let shared = MeManager()
    
    fileprivate var worker: MeWorkerProtocl!
    
    init() {
        worker = MoveApiMeWorker()
    }
    
    func checkCurrentRole() -> Observable<Bool?> {
        return Observable.empty()
    }
    
}

extension UserManager {
    
    func isValid() -> Observable<Bool> {
        return Observable.just(UserInfo.shared.accessToken.isValidAndNotExpired)
    }
    
}
