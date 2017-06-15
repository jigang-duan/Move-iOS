//
//  ImNoticeType.swift
//  Move App
//
//  Created by jiang.duan on 2017/5/17.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation


enum FirmwareUpdateType {
    case updateStarted(String)
    case updateSucceed(String)
    case updateDefeated(String)
    case downloadStarted(String)
    case downloadDefeated(String)
    case checkDefeated(String)
    
    case progressDownload(String, Int)
    
    case empty
}


extension FirmwareUpdateType {
    
    var progress: Int {
        switch self {
        case .progressDownload( _, let val):
            return val
        case .updateStarted, .downloadStarted:
            return 0
        case .updateSucceed:
            return 100
        case .checkDefeated, .updateDefeated, .downloadDefeated:
            return -1
        case .empty:
            return -100
        }
    }
    
    var deviceUID: String {
        switch self {
        case .updateStarted(let devUId):
            return devUId
        case .updateSucceed(let devUId):
            return devUId
        case .updateDefeated(let devUId):
            return devUId
        case .downloadStarted(let devUId):
            return devUId
        case .downloadDefeated(let devUId):
            return devUId
        case .checkDefeated(let devUId):
            return devUId
        case .progressDownload(let devUId, _):
            return devUId
        case .empty:
            return ""
        }
    }
}



extension FirmwareUpdateType {
    
    init?(notice: NoticeEntity) {
        guard let type = NoticeType(rawValue: notice.type) else {
            return nil
        }
        
        let devUId = notice.from ?? ""
        
        switch type {
        case .progressDownload:
            let val = Int(notice.content ?? "") ?? 0
            self = .progressDownload(devUId, val)
        case .deviceUpdateStarted:
            self = .updateStarted(devUId)
        case .deviceUpdateSucceed:
            self = .updateSucceed(devUId)
        case .deviceUpdateDefeated:
            self = .updateDefeated(devUId)
        case .deviceDownloadStarted:
            self = .downloadStarted(devUId)
        case .deviceDownloadDefeated:
            self = .downloadDefeated(devUId)
        case .deviceCheckDefeated:
            self = .checkDefeated(devUId)
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
    case generalUnpairWatch
    
    case familyPhoneNumberChanged
    case watchOnlineOffline
    case watchChangeSIMCard
    
    case appUpdate
    case firmwareUpdate
    
    case newFirmwareUpdate
    case firmwareUpdateInformation
    case firmwareUpdateState
    case progressDownload
    
    case manuallyLocate
 
    case unknown
}

extension ImNoticeType {
    
    var isFirmwareUpdate: Bool {
        switch self {
        case .firmwareUpdateInformation, .progressDownload, .firmwareUpdateState:
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
        case .appUpdate, .firmwareUpdate:
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
        case .unknown, .newFirmwareUpdate, .firmwareUpdateState, .firmwareUpdate, .appUpdate:
            return false
        default:
            return true
        }
    }
    
    var isShowPopup: Bool {
        switch self {
        case .unknown, .kidsAddANewFriend,
             .generalUnpairWatch, .familyPhoneNumberChanged,
             .watchOnlineOffline, .watchChangeSIMCard,
             .manuallyLocate, .firmwareUpdateState:
            return false
        default:
            return true
        }
    }
    
    var needSave: Bool {
        return (self != .progressDownload) && (self != .manuallyLocate) && (self != .unknown)
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
    
    var okDescription: String {
        switch self {
        case .update, .download:
            return "Not now"
        default:
            return R.string.localizable.id_ok()
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
        case .generalUnpairWatch:
            return .unpired
        case .familyPhoneNumberChanged:
            return .goToSee
        case .watchOnlineOffline:
            return .default
        case .watchChangeSIMCard:
            return .goToSee
        case .appUpdate:
            return .update
        case .newFirmwareUpdate, .firmwareUpdate:
            return .download
        case .firmwareUpdateInformation, .firmwareUpdateState:
            return .default
        case .progressDownload:
            return .default
        case .manuallyLocate:
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
            self = (notice.owners.first?.owner == notice.from) ? .masterUnpairWatch : .generalUnpairWatch
            
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
            self = .firmwareUpdateState
        case .deviceDownloadDefeated:
            self = .firmwareUpdateInformation
        case .deviceCheckDefeated:
            self = .firmwareUpdateState
        case .deviceDownloadStarted:
            self = .firmwareUpdateState
            
        case .instantPosition:
            self = .manuallyLocate
            
        case .appUpdateVersion:
            self = .appUpdate
        case .deviceUpdateVersion:
            self = .firmwareUpdate
        
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
        case .chatMessage:
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
