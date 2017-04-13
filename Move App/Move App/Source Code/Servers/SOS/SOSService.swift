//
//  SOSService.swift
//  Move App
//
//  Created by jiang.duan on 2017/4/12.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SOSService {
    
    static let shared = SOSService()
    
    let subject = ReplaySubject<KidSate.SOSLbsModel>.create(bufferSize: 1)
    
    func handle(_ sos: KidSate.SOSLbsModel) {
        subject.onNext(sos)
    }
}
