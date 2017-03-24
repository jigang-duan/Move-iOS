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


extension NoticeType {
    
    var title: String? {
        switch self {
        case .newContact:
            return nil
        case .bindRandomCode:
            return nil
        case .instantPosition:
            return nil
        case .intoFence:
            return "Warning"
        case .outFence:
            return "Warning"
        case .lowBattery:
            return "Warning"
        case .sos:
            return "Warning"
        case .unbound:
            return nil
        case .numberChanged:
            return nil
        case .powered:
            return nil
        case .shutdown:
            return nil
        case .roam:
            return nil
        case .update:
            return nil
        case .thumbUpFromSportsFriend:
            return ""
        case .thumbUpFromGameFriend:
            return nil
        case .groupInvited:
            return nil
        case .firmwareDownload:
            return nil
        case .progressDownload:
            return nil
        case .configurationUpdated:
            return nil
        case .wear:
            return nil
        case .loss:
            return nil
        case .deviceNumberChanged:
            return nil
        case .unknown:
            return nil
        }
    }
}

extension NoticeType: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .newContact:
            return "%@ has added a new friend %@"
        case .bindRandomCode:
            return ""
        case .instantPosition:
            return ""
        case .intoFence:
            return "%@ is enter of safe zone home"
        case .outFence:
            return "%@ is out of safe zone home"
        case .lowBattery:
            return "Only %d% battery left"
        case .sos:
            return "%@ has sent an SOS alert"
        case .unbound:
            return "Master has unpaired this watch"
        case .numberChanged:
            return "%@'s phone number has been changed"
        case .powered:
            return "%@ is online"
        case .shutdown:
            return "%@ is offline"
        case .roam:
            return ""
        case .update:
            return ""
        case .thumbUpFromSportsFriend:
            return ""
        case .thumbUpFromGameFriend:
            return ""
        case .groupInvited:
            return ""
        case .firmwareDownload:
            return ""
        case .progressDownload:
            return ""
        case .configurationUpdated:
            return ""
        case .wear:
            return ""
        case .loss:
            return ""
        case .deviceNumberChanged:
            return "%@ has changed SIM card number to %@"
        case .unknown:
            return "unknow"
        }
    }
}
