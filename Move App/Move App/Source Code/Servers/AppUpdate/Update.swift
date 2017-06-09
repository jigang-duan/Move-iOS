//
//  Update.swift
//  Move App
//
//  Created by jiang.duan on 2017/5/23.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift


class UpdateServer {
    
    static let shared = UpdateServer()
    
    static var currentAppVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    func appUdateNoctice() -> Observable<NoticeEntity> {
        return ItunesApi.lookup()
            .filter { versionCompare($0.version, UpdateServer.currentAppVersion) }
            .filter { versionCompare($0.version, ImDateBase.shared.appVsersion) }
            .map { NoticeEntity(itunesLookupItem: $0) }
    }
    
    func deviceUpdateNoctice(device id: String, uid: String, devUID: String, name: String) -> Observable<NoticeEntity> {
        return DeviceManager.shared.newVersions(device: id)
            .filter { versionCompare($0, ImDateBase.shared.deviceVsersion(uid: uid, devUID: devUID)) }
            .map { NoticeEntity(newVersions: $0, uid: uid, devUID: devUID, name: name) }
    }
}


fileprivate extension NoticeEntity {
    convenience init(itunesLookupItem: ItunesLookupItem) {
        self.init()
        self.id = "\(Date().timeIntervalSince1970),itunes"
        self.content = itunesLookupItem.version
        self.readStatus = ReadStatus.unread.rawValue
        self.type = NoticeType.appUpdateVersion.rawValue
        self.createDate = Date()
    }
    
    convenience init(newVersions: String, uid: String, devUID: String, name: String) {
        self.init()
        self.id = "\(Date().timeIntervalSince1970),\(devUID)"
        self.from = devUID
        self.to = uid
        self.content = String(format: "New version for %@'s watch", name)
        self.readStatus = ReadStatus.unread.rawValue
        self.type = NoticeType.deviceUpdateVersion.rawValue
        self.createDate = Date()
    }
}


fileprivate func versionCompare(_ new: String?, _ old: String?) -> Bool {
    guard let new = new else { return false }
    guard let old = old else { return true }
    let vnew = new.components(separatedBy: ".").flatMap{ Int($0) }
    let vold = old.components(separatedBy: ".").flatMap{ Int($0) }
    let minCount = vnew.count < vold.count ? vnew.count : vold.count
    for i in 0 ..< minCount {
        if vnew[i] != vold[i] {
            return vnew[i] > vold[i]
        }
    }
    return false
}
