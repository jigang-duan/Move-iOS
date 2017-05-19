//
//  ImNoticeType.swift
//  Move App
//
//  Created by jiang.duan on 2017/5/17.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation


enum FirmwareUpdateType {
    case updateStarted
    case updateSucceed
    case updateDefeated
    case downloadStarted
    case downloadDefeated
    case checkDefeated
    
    case progressDownload(Int)
}

extension FirmwareUpdateType {
    
    var progress: Int {
        switch self {
        case .progressDownload(let val):
            return val
        case .updateStarted, .downloadStarted:
            return 0
        case .updateSucceed:
            return 100
        case .checkDefeated, .updateDefeated, .downloadDefeated:
            return -1
        }
    }
    
}

extension FirmwareUpdateType {
    
    init?(notice: NoticeEntity) {
        guard let type = NoticeType(rawValue: notice.type) else {
            return nil
        }
        
        switch type {
        case .progressDownload:
            let val = Int(notice.content ?? "") ?? 0
            self = .progressDownload(val)
        case .deviceUpdateStarted:
            self = .updateStarted
        case .deviceUpdateSucceed:
            self = .updateSucceed
        case .deviceUpdateDefeated:
            self = .updateDefeated
        case .deviceDownloadStarted:
            self = .downloadStarted
        case .deviceDownloadDefeated:
            self = .downloadDefeated
        case .deviceCheckDefeated:
            self = .checkDefeated
        default:
            return nil
        }
    }
}


// MARK: - IM Notice Type
/// -- 与 UI ergo 定义一致
/// -- 区别于NoticeType与服务器接口类型一致

enum ImNoticeType {
    
    case safezoneAlert
    case lowBatteryAlert
    case sosWarning
    case kidsAddANewFriend
    case masterUnpairWatch
    case generalUserUnpairWatch
    case masterDeleteAGeneralUser
    case familyPhoneNumberChanged
    case watchOnlineOffline
    case watchChangeSIMCard
    
    case appUpdate
    
    case newFirmwareUpdate
    case firmwareUpdateInformation
    case progressDownload
 
    case unknown
}

extension ImNoticeType {
    
    var isFirmwareUpdate: Bool {
        switch self {
        case .firmwareUpdateInformation, .progressDownload:
            return true
        default:
            return false
        }
    }
    
}

extension ImNoticeType {
    
    var title: String? {
        switch self {
        case .safezoneAlert:
            return R.string.localizable.id_warming()
        case .lowBatteryAlert:
            return R.string.localizable.id_warming()
        case .sosWarning:
            return R.string.localizable.id_warming()
        case .masterUnpairWatch:
            return nil
        case .appUpdate:
            return nil
        case .newFirmwareUpdate:
            return nil
        case .firmwareUpdateInformation:
            return nil
        default:
            return nil
        }
    }
}

extension ImNoticeType {
    
    var atNotiicationPage: Bool {
        switch self {
        case .unknown, .newFirmwareUpdate:
            return false
        default:
            return true
        }
    }
}

extension ImNoticeType {
    
    var isShowPopup: Bool {
        switch self {
        case .unknown, .kidsAddANewFriend, .generalUserUnpairWatch, .familyPhoneNumberChanged, .watchOnlineOffline, .watchChangeSIMCard:
            return false
        default:
            return true
        }
    }
}

enum NoticeAlertStyle {
    case `default`
    case navigate
    case unpired
    case goToSee
    case update
    case download
}

extension NoticeAlertStyle : CustomStringConvertible {
    var description: String {
        switch self {
        case .default:
            return ""
        case .navigate:
            return "Navigate"
        case .unpired:
            return R.string.localizable.id_ok()
        case .goToSee:
            return R.string.localizable.id_system_notice_go_to_see()
        case .update:
            return "Update"
        case .download:
            return "Download"
        }
    }
}

extension NoticeAlertStyle {
    var hasConfirm: Bool {
        switch self {
        case .default, .unpired:
            return false
        case .navigate, .goToSee, .update, .download:
            return true
        }
    }
}

extension ImNoticeType {
    var style: NoticeAlertStyle {
        switch self {
        case .safezoneAlert:
            return .navigate
        case .lowBatteryAlert:
            return .default
        case .sosWarning:
            return .navigate
        case .kidsAddANewFriend:
            return .goToSee
        case .masterUnpairWatch:
            return .unpired
        case .generalUserUnpairWatch:
            return .unpired
        case .masterDeleteAGeneralUser:
            return .unpired
        case .familyPhoneNumberChanged:
            return .goToSee
        case .watchOnlineOffline:
            return .default
        case .watchChangeSIMCard:
            return .goToSee
        case .appUpdate:
            return .update
        case .newFirmwareUpdate:
            return .download
        case .firmwareUpdateInformation:
            return .default
        case .progressDownload:
            return .default
        case .unknown:
            return .default
        }
    }
}

extension ImNoticeType {

    init(notice: NoticeEntity) {
        guard let type = NoticeType(rawValue: notice.type) else {
            self = .unknown
            return
        }
        
        switch type {
            
        case .newContact:
            self = .kidsAddANewFriend
        
        case .intoFence:
            self = .safezoneAlert
        case .outFence:
            self = .safezoneAlert
            
        case .lowBattery:
            self = .lowBatteryAlert
            
        case .sos:
            self = .sosWarning
            
        case .unbound:
            if notice.groupId == nil || notice.groupId == ""  {
                self = (notice.owners.first?.owner == notice.to) ? .generalUserUnpairWatch : .masterDeleteAGeneralUser
            } else {
                self = .masterUnpairWatch
            }
            
        case .numberChanged:
            self = .familyPhoneNumberChanged
            
        case .powered:
            self = .watchOnlineOffline
        case .shutdown:
            self = .watchOnlineOffline
        
        case .deviceNumberChanged:
            self = .watchChangeSIMCard
        
        case .progressDownload:
            self = .progressDownload
       
        case .deviceUpdateSucceed:
            self = .firmwareUpdateInformation
        case .deviceUpdateDefeated:
            self = .firmwareUpdateInformation
        case .deviceUpdateStarted:
            self = .firmwareUpdateInformation
        case .deviceDownloadDefeated:
            self = .firmwareUpdateInformation
        case .deviceCheckDefeated:
            self = .firmwareUpdateInformation
        case .deviceDownloadStarted:
            self = .firmwareUpdateInformation
        
        case .deviceConfigurationUpdated:
            self = .unknown
        case .deviceWear:
            self = .unknown
        case .deviceLoss:
            self = .unknown
        case .thumbUpFromSportsFriend:
            self = .unknown
        case .thumbUpFromGameFriend:
            self = .unknown
        case .groupInvited:
            self = .unknown
        case .roam:
            self = .unknown
        case .bindRandomCode:
            self = .unknown
        case .instantPosition:
            self = .unknown
        case .unknown:
            self = .unknown
        }
    }
}

extension NoticeEntity {

    var imType: ImNoticeType {
        return ImNoticeType(notice: self)
    }

}
