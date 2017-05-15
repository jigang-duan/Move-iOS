//
//  DBIMWorker.swift
//  Move App
//
//  Created by jiang.duan on 2017/5/15.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift

class DBIMWorker: IMChatWorkerProtocl {
    
    func countUnreadMessages(uid: String, devUid: String) -> Observable<Int> {
        return ImDateBase.shared.fetchUnreadMessageCount(uid: uid, devUid: devUid)
    }
}
