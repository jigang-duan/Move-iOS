//
//  Notice.swift
//  Move App
//
//  Created by jiang.duan on 2017/3/15.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

/*
 1 - 新增联系人
 2 - 绑定随机码
 3 - 即时位置
 4 - 进电子围栏
 5 - 出电子围栏
 6 - 低电量
 7 - SOS
 8 - 解除绑定
 9 - 更改号码
 10 - 设备开机
 11 - 设备关机
 12 - 设备漫游
 13 - 设备升级成功
 14 - 运动好友点赞
 15 - 游戏好友点赞
 16 - 群组邀请
 17 - 固件开始下载
 18 - 固件下载进度
 19 - 设备配置更新
 20 - 设备穿戴
 21 - 设备脱落
 22 - 设备更换号码
 23 - 设备升级失败
 24 - 设备开始升级
 25 - 固件下载失败，需重新下载
 26 - 手表check下载url失败
 
 400 - APP升级版本
 401 - 固件升级版本
 */
// MARK: - Notice Type
/// -- 与 服务器接口类型 定义一致
/// -- 区别于ImNoticeType与UI层类型一致
enum NoticeType: Int {
    case newContact = 1
    case bindRandomCode = 2
    case instantPosition = 3
    case intoFence = 4
    case outFence = 5
    case lowBattery = 6
    case sos = 7
    case unbound = 8
    case numberChanged = 9
    case powered = 10
    case shutdown = 11
    case roam = 12
    case deviceUpdateSucceed = 13
    case thumbUpFromSportsFriend = 14
    case thumbUpFromGameFriend = 15
    case groupInvited = 16
    case deviceDownloadStarted = 17
    case progressDownload = 18
    case deviceConfigurationUpdated = 19
    case deviceWear = 20
    case deviceLoss = 21
    case deviceNumberChanged = 22
    case deviceUpdateDefeated = 23
    case deviceUpdateStarted = 24
    case deviceDownloadDefeated = 25
    case deviceCheckDefeated = 26
    
    case appUpdateVersion = 400
    case deviceUpdateVersion = 401
    
    case unknown = -1
}


class NoticeEntity: Object {
    
    enum ReadStatus: Int {
        case unread = 0
        case read = 1
        case unknown = -1
    }
    
    dynamic var id: String? = nil
    dynamic var from: String? = nil
    dynamic var to: String? = nil
    dynamic var groupId: String? = nil
    dynamic var content: String?
    dynamic var readStatus = ReadStatus.unknown.rawValue
    dynamic var type = NoticeType.unknown.rawValue
    dynamic var createDate: Date? = nil
    
    let owners = LinkingObjects(fromType: GroupEntity.self, property: "notices")
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}

extension NoticeEntity {
    
    func makeRead(realm: Realm) {
        try? realm.write {
            self.readStatus = ReadStatus.read.rawValue
        }
    }
}

