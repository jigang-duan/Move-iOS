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
 13 - 设备更新
 14 - 运动好友点赞
 15 - 游戏好友点赞
 16 - 群组邀请
 17 - 固件下载
 18 - 下载进度
 19 - 设备配置更新
 20 - 设备穿戴
 21 - 设备脱落
 22 - 设备更换号码
 */
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
    case update = 13
    case thumbUpFromSportsFriend = 14
    case thumbUpFromGameFriend = 15
    case groupInvited = 16
    case firmwareDownload = 17
    case progressDownload = 18
    case configurationUpdated = 19
    case wear = 20
    case loss = 21
    case deviceNumberChanged = 22
    case unknown = -1
}

enum ReadStatus: Int {
    case unread = 0
    case read = 1
    case unknown = -1
}


class NoticeEntity: Object {
    
    dynamic var noticeId: String? = nil
    dynamic var fromId: String? = nil
    dynamic var toId: String? = nil
    dynamic var gid: String? = nil
    dynamic var content: String?
    dynamic var readStatus = ReadStatus.unknown.rawValue
    dynamic var type = NoticeType.unknown.rawValue
    dynamic var ctime: Data? = nil
    
    override static func primaryKey() -> String? {
        return "noticeId"
    }
    
}
