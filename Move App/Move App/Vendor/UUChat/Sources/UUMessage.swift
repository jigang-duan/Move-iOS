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
    case dizzy = "[dizzy]"
    case heart = "[heart]"
    case crying = "[crying]"
    case laugh = "[laugh]"
    case naughty = "[naughty]"
    case sad = "[sad]"
    case sick = "[sick]"
    case smile = "[smile]"
    case aweat_d = "[aweat_d]"
    case bye_d = "[bye_d]"
    case dizzy_d = "[dizzy_d]"
    case heart_d = "[heart_d]"
    case cry_d = "[cry_d]"
    case laugh_d = "[laugh_d]"
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
    
    var showDateLabel: Bool = true
    
    mutating func minuteOffSet(start: Date, end: Date) {
        //这个是相隔的秒数
        let timeInterval = start.timeIntervalSince(end)
        //相距5分钟显示时间Label
        self.showDateLabel = fabs(timeInterval) > _minute(5)
    }
    
    var strTime: String {
        return self.showTheDate(time)
    }
    
    private func showTheDate(_ lastDate: Date) -> String {
        
        let nowDate = Date()
        var dateStr: String = ""
        var period: String = ""
        var hour: String = ""
        
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
                         showDateLabel: true)
    }

    
}


fileprivate func _minute(_ n: TimeInterval) -> TimeInterval {
    return n * 60.0
}



extension EmojiType {
    
    var url: URL? {
        switch self {
        case .aweat:
            return R.file.emotion_11Png()
        case .bye:
            return R.file.emotion_12Png()
        case .dizzy:
            return R.file.emotion_14Png()
        case .heart:
            return R.file.emotion_15Png()
        case .crying:
            return R.file.emotion_16Png()
        case .laugh:
            return R.file.emotion_17Png()
        case .naughty:
            return R.file.emotion_18Png()
        case .sad:
            return R.file.emotion_19Png()
        case .sick:
            return R.file.emotion_21Png()
        case .smile:
            return R.file.emotion_22Png()
        case .aweat_d:
            return R.file.emotion_01Gif()
        case .bye_d:
            return R.file.emotion_02Gif()
        case .dizzy_d:
            return R.file.emotion_03Gif()
        case .heart_d:
            return R.file.emotion_04Gif()
        case .cry_d:
            return R.file.emotion_05Gif()
        case .laugh_d:
            return R.file.emotion_06Gif()
        case .naughty_d:
            return R.file.emotion_07Gif()
        case .sad_d:
            return R.file.emotion_08Gif()
        case .sick_d:
            return R.file.emotion_09Gif()
        case .smile_d:
            return R.file.emotion_10Gif()
        default:
            return nil
        }
    }

    var isGit: Bool {
        switch self {
        case .aweat:
            return false
        case .bye:
            return false
        case .dizzy:
            return false
        case .heart:
            return false
        case .crying:
            return false
        case .laugh:
            return false
        case .naughty:
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
        case .heart_d:
            return true
        case .cry_d:
            return true
        case .laugh_d:
            return true
        case .naughty_d:
            return true
        case .sad_d:
            return true
        case .sick_d:
            return true
        case .smile_d:
            return true
        default:
            return false
        }
    }
}

extension EmojiType: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .aweat:
            return "[aweat]"
        case .bye:
            return "[bye]"
        case .dizzy:
            return "[dizzy]"
        case .heart:
            return "[heart]"
        case .crying:
            return "[crying]"
        case .laugh:
            return "[laugh]"
        case .naughty:
            return "[naughty]"
        case .sad:
            return "[sad]"
        case .sick:
            return "[sick]"
        case .smile:
            return "[smile]"
        case .aweat_d:
            return "[aweat_d]"
        case .bye_d:
            return "[bye_d]"
        case .dizzy_d:
            return "[dizzy_d]"
        case .heart_d:
            return "[heart_d]"
        case .cry_d:
            return "[cry_d]"
        case .laugh_d:
            return "[laugh_d]"
        case .naughty_d:
            return "[naughty_d]"
        case .sad_d:
            return "[sad_d]"
        case .sick_d:
            return "[sick_d]"
        case .smile_d:
            return "[smile_d]"
        default:
            return "⚠️"
        }
    }

}
