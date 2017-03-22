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
}

enum MessageFrom {
    case me             // 自己发的
    case other          // 别人发得
}

enum MessageState {
    case unread
    case read
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
