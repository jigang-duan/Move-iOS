//
//  UUMessage.swift
//  UUChat
//
//  Created by jiang.duan on 2017/3/1.
//  Copyright © 2017年 jiang.duan. All rights reserved.
//

import UIKit

enum MessageType: Int {
    case text = 0       // 文字
    case picture = 1    // 图片
    case voice = 2      // 语音
    case video = 3      // 视频
    case emoji = 4
}

enum MessageFrom {
    case me             // 自己发的
    case other          // 别人发得
}

enum MessageState {
    case unread
    case read
}


enum EmojiType: String {
    case aweat = "[aweat]"
    case bye = "[bye]"
    case cry = "[cry]"
    case heart = "[heart]"
    case lacrimation = "[lacrimation]"
    case smile = "[smile]"
    case angry = "[angry]"
    case sad = "[sad]"
    case sick = "[sick]"
    case dizzy = "[dizzy]"
    
    case aweat_d = "[aweat_d]"
    case bye_d = "[bye_d]"
    case dizzy_d = "[dizzy_d]"
    case loveu_d = "[loveu_d]"
    case cry_d = "[cry_d]"
    case laught_d = "[laught_d]"
    case naughty_d = "[naughty_d]"
    case sad_d = "[sad_d]"
    case sick_d = "[sick_d]"
    case smile_d = "[smile_d]"
    
    case warning = "⚠️"
}


struct UUMessage {
    
    var icon: String
    var msgId: String
    var time: Date
    var name: String
    
    struct Content {
        var text: String?
        var picture: Picture?
        var voice: UUMessage.Voice?
        var video: Video?
        var emoji: EmojiType? = nil
    }
    
    struct Picture {
        var image: UIImage?
        var url: String?
    }
    
    struct Voice {
        var data: Data?
        var url: URL?
        var second: Int?
    }
    
    struct Video {
        var data: Data?
        var url: String?
        var second: Int?
    }
    
    
    var content: Content
    var state: MessageState
    
    var type: MessageType
    var from: MessageFrom
    
    var isFailure: Bool = false
    
    var showDateLabel: Bool = true
    
    mutating func minuteOffSet(start: Date, end: Date) {
        //这个是相隔的秒数
        let timeInterval = start.timeIntervalSince(end)
        //相距5分钟显示时间Label
        self.showDateLabel = fabs(timeInterval) > _minute(5)
    }
    
    var strTime: String {
        return self.showTheLocalDate(time)
    }
    
    private func showTheLocalDate(_ lastDate: Date) -> String {
        
        let nowDate = Date()
        var dateStr: String = ""
        
        let days = Date.daysOffBetween(startDate: lastDate, endDate: nowDate)
        var str: String? = nil
        if days <= 2 {
            str = lastDate.stringYearMonthDayCompareToday?.rawValue
        }
        if str == nil {
            dateStr = lastDate.stringDefaultYearMonthDay
        } else {
            dateStr = str!
        }
        
        return String(format: "%@ %@", dateStr, lastDate.stringDefaultHourMinuteSecond)
    }
    
    private func showTheDate(_ lastDate: Date) -> String {
        
        let nowDate = Date()
        var dateStr: String = ""
        var period: String = ""
        var hour: String = ""
        
        guard ShowDateMode_isCompare else {
            dateStr = lastDate.stringYearMonthDay
            return String(format: "%@ %02d:%02d", dateStr, lastDate.hour, lastDate.minute)
        }
        
        if lastDate.year == nowDate.year {
            let days = Date.daysOffBetween(startDate: lastDate, endDate: nowDate)
            var str: String? = nil
            if days <= 2 {
                str = lastDate.stringYearMonthDayCompareToday?.rawValue
            }
            if str == nil {
                dateStr = lastDate.stringMonthDay
            } else {
                dateStr = str!
            }
        } else {
            dateStr = lastDate.stringYearMonthDay
        }
        
        if (lastDate.hour >= 5) && (lastDate.hour < 12) {
            period = "AM"
            hour = String(format: "%02d", lastDate.hour)
        } else if (lastDate.hour >= 12) && (lastDate.hour <= 18) {
            period = "PM"
            hour = String(format: "%02d", lastDate.hour - 12)
        } else if (lastDate.hour > 18) && (lastDate.hour <= 23) {
            period = "Night"
            hour = String(format: "%02d", lastDate.hour - 12)
        } else {
            period = "Dawn"
            hour = String(format: "%02d", lastDate.hour)
        }
        
        return String(format: "%@ %@ %@:%02d", dateStr, period, hour, lastDate.minute)
    }
}

fileprivate let ShowDateMode_isCompare = true

extension UUMessage {
    
    static func myTextMessage(_ text: String, icon: String, name: String) -> UUMessage {
        var messageContent = UUMessage.Content()
        messageContent.text = text
        return UUMessage(icon: icon,
                         msgId: "",
                         time: Date(),
                         name: name,
                         content: messageContent,
                         state: .read,
                         type: .text,
                         from: .me,
                         isFailure: false,
                         showDateLabel: true)
    }
    
    static func myPictureMessage(_ picture: UIImage, icon: String, name: String) -> UUMessage {
        var messageContent = UUMessage.Content()
        messageContent.picture = UUMessage.Picture(image: picture, url: nil)
        return UUMessage(icon: icon,
                         msgId: "",
                         time: Date(),
                         name: name,
                         content: messageContent,
                         state: .read,
                         type: .picture,
                         from: .me,
                         isFailure: false,
                         showDateLabel: true)
    }
    
    static func myVoiceMessage(_ voice: Data, second: Int, icon: String, name: String) -> UUMessage {
        var messageContent = UUMessage.Content()
        messageContent.voice = UUMessage.Voice(data: voice, url: nil, second: second)
        return UUMessage(icon: icon,
                         msgId: "",
                         time: Date(),
                         name: name,
                         content: messageContent,
                         state: .read,
                         type: .voice,
                         from: .me,
                         isFailure: false,
                         showDateLabel: true)
    }
    
    static func VoiceMessageForURL(_ voice: URL, second: Int, icon: String, name: String) -> UUMessage {
        var messageContent = UUMessage.Content()
        messageContent.voice = UUMessage.Voice(data: nil, url: voice, second: second)
        return UUMessage(icon: icon,
                         msgId: "",
                         time: Date(),
                         name: name,
                         content: messageContent,
                         state: .read,
                         type: .voice,
                         from: .me,
                         isFailure: false,
                         showDateLabel: true)
    }

    
}


fileprivate func _minute(_ n: TimeInterval) -> TimeInterval {
    return n * 60.0
}


extension EmojiType {
    
    static func getEmojis() -> [[EmojiType]] {
        return [
            [.aweat, .bye, .cry, .heart, .lacrimation, .smile, .angry, .sad, .sick, .dizzy],
            [.aweat_d,.bye_d, .dizzy_d, .loveu_d, .cry_d, laught_d, naughty_d, sad_d, sick_d, smile_d]
        ]
    }
    
    private var emotionDynamicURL: URL? {
        return R.file.emotion_Dynamic_144()
//        return R.file.emotion_PNG_180()
    }
    
    var url: URL? {
        switch self {
        case .aweat:
            return R.file.emotion_21Png()
        case .bye:
            return R.file.emotion_22Png()
        case .dizzy:
            return R.file.emotion_30Png()
        case .heart:
            return R.file.emotion_24Png()
        case .lacrimation:
            return R.file.emotion_25Png()
        case .angry:
            return R.file.emotion_27Png()
        case .cry:
            return R.file.emotion_23Png()
        case .sad:
            return R.file.emotion_28Png()
        case .sick:
            return R.file.emotion_29Png()
        case .smile:
            return R.file.emotion_26Png()
            
//        case .aweat_d:
//            return emotionDynamicURL?.appendingPathComponent("aweat", isDirectory: true)
//        case .bye_d:
//            return emotionDynamicURL?.appendingPathComponent("bye", isDirectory: true)
//        case .dizzy_d:
//            return emotionDynamicURL?.appendingPathComponent("dizzy", isDirectory: true)
//        case .loveu_d:
//            return emotionDynamicURL?.appendingPathComponent("loveu", isDirectory: true)
//        case .cry_d:
//            return emotionDynamicURL?.appendingPathComponent("cry", isDirectory: true)
//        case .laught_d:
//            return emotionDynamicURL?.appendingPathComponent("laugh", isDirectory: true)
//        case .naughty_d:
//            return emotionDynamicURL?.appendingPathComponent("naughty", isDirectory: true)
//        case .sad_d:
//            return emotionDynamicURL?.appendingPathComponent("sad", isDirectory: true)
//        case .sick_d:
//            return emotionDynamicURL?.appendingPathComponent("sick", isDirectory: true)
//        case .smile_d:
//            return emotionDynamicURL?.appendingPathComponent("smile", isDirectory: true)
            
        case .aweat_d:
            return R.file.aweatGif()
        case .bye_d:
            return R.file.byeGif()
        case .dizzy_d:
            return R.file.dizzyGif()
        case .loveu_d:
            return R.file.loveu_2Gif()
        case .cry_d:
            return R.file.cryGif()
        case .laught_d:
            return R.file.laughGif()
        case .naughty_d:
            return R.file.naughtyGif()
        case .sad_d:
            return R.file.sadGif()
        case .sick_d:
            return R.file.sickGif()
        case .smile_d:
            return R.file.smileGif()
            
        case .warning:
            return nil
        }
    }
    
    var duration: TimeInterval {
        switch self {
        case .aweat:
            return 0
        case .bye:
            return 0
        case .dizzy:
            return 0
        case .heart:
            return 0
        case .lacrimation:
            return 0
        case .angry:
            return 0
        case .cry:
            return 0
        case .sad:
            return 0
        case .sick:
            return 0
        case .smile:
            return 0
        case .aweat_d:
            return 4.0
        case .bye_d:
            return 1.0
        case .dizzy_d:
            return 2.0
        case .loveu_d:
            return 3.0
        case .cry_d:
            return 3.0
        case .laught_d:
            return 0.18
        case .naughty_d:
            return 2.0
        case .sad_d:
            return 4.0
        case .sick_d:
            return 4.0
        case .smile_d:
            return 2.0
        case .warning:
            return 0
        }
    }

    var isDynamic: Bool {
        switch self {
        case .aweat:
            return false
        case .bye:
            return false
        case .dizzy:
            return false
        case .heart:
            return false
        case .lacrimation:
            return false
        case .angry:
            return false
        case .cry:
            return false
        case .sad:
            return false
        case .sick:
            return false
        case .smile:
            return false
        case .aweat_d:
            return true
        case .bye_d:
            return true
        case .dizzy_d:
            return true
        case .loveu_d:
            return true
        case .cry_d:
            return true
        case .laught_d:
            return true
        case .naughty_d:
            return true
        case .sad_d:
            return true
        case .sick_d:
            return true
        case .smile_d:
            return true
        case .warning:
            return false
        }
    }
}

extension EmojiType: CustomStringConvertible {
    
    var description: String {
        return self.rawValue
    }

}
