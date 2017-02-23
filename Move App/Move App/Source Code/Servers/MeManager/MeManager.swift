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
    func checkRoles() -> Observable<[Role]>
    func checkCurrentRole() -> Observable<Role?>
}


class MeManager {
    static let shared = MeManager()
    
    fileprivate var worker: MeWorkerProtocl!
    private let me = Me.shared
    
    init() {
        worker = MoveApiMeWorker()
    }
    
    func checkRoles() -> Observable<[Role]> {
        return worker.checkRoles()
    }
    
    func checkCurrentRole() -> Observable<Role?> {
        return worker.checkCurrentRole()
    }
}

extension UserManager {
    
    func isValid() -> Observable<Bool> {
        return Observable.just(UserInfo.shared.accessToken.isValidAndNotExpired)
    }
    
}
