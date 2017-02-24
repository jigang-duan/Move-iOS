//
//  KidSettingManager.swift
//  Move App
//
//  Created by jiang.duan on 2017/2/24.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift

/// User KidSettings Protocl
protocol KidSettingsWorkerProtocl {
    func fetchSchoolTime() -> Observable<KidSetting.SchoolTime>
}


class KidSettingsManager {
    static let shared = KidSettingsManager()
    
    fileprivate var worker: KidSettingsWorkerProtocl!
    private let kidSettings = KidSettingsManager.shared
    
    init() {
        worker = nil
    }
    
    func fetchSchoolTime() -> Observable<KidSetting.SchoolTime> {
        return self.worker.fetchSchoolTime()
    }
}
