//
//  DateUtility.swift
//  Move App
//
//  Created by jiang.duan on 2017/2/27.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation

class DateUtility {
    
    static let SEC_DAY: TimeInterval = 24 * 60 * 60
    static let SEC_HDAY: TimeInterval = DateUtility.SEC_DAY * 0.5
    
    static func date(from text: String?) -> Date {
        guard let _text = text else {
            return Date(timeIntervalSince1970: 0)
        }
        let dformatter = DateFormatter()
        dformatter.timeZone = TimeZone(secondsFromGMT: 0)
        dformatter.dateFormat = "HH:mm"
        return dformatter.date(from: _text) ?? Date(timeIntervalSince1970: 0)
    }
    
    static func dateTostringHHmm(date: Date?) -> String {
        
        let dformatter = DateFormatter()
        dformatter.dateFormat = "HH:mm"
        return dformatter.string(from: date ?? Date(timeIntervalSince1970: 0))
        
    }
    static func dateTostringyyMMdd(date: Date?) -> String {
        
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy-MM-dd"
        return dformatter.string(from: date ?? Date(timeIntervalSince1970: 0))
        
    }
    static func dateTostringMMddyy(date: Date?) -> String {
        
        let dformatter = DateFormatter()
        dformatter.dateFormat = "MM-dd-yyyy"
        return dformatter.string(from: date ?? Date(timeIntervalSince1970: 0))
        
    }
    
    static func zoneDay() -> (startDate: Date, endDate: Date) {
        let now = Date(timeIntervalSince1970: 0)
        return (now,now.addingTimeInterval(DateUtility.SEC_DAY))
    }
    
    static func zone7hour() -> Date {
        return DateUtility.zoneDay().startDate.addingTimeInterval(25200)
    }
    
    static func zone12hour() -> Date {
        return DateUtility.zoneDay().startDate.addingTimeInterval(43200)
    }
    static func zone14hour() -> Date {
        return DateUtility.zoneDay().startDate.addingTimeInterval(50400)
    }
    static func zone16hour() -> Date {
        return DateUtility.zoneDay().startDate.addingTimeInterval(61200)
    }
    static func zone11hour() -> Date
    {
        return DateUtility.zoneDay().startDate.addingTimeInterval(39600)
    }
    
    static func zoneDayOfHMS(date: Date) -> Date {
        return Date(timeIntervalSince1970: date.timeIntervalSince1970.truncatingRemainder(dividingBy: SEC_DAY))
    }
    
    func today() -> (startDate: Date, endDate: Date) {
        let calendar = Calendar.current
        let now = Date()
        var set = Set<Calendar.Component>()
        set.insert(.year)
        set.insert(.month)
        set.insert(.day)
        let components = calendar.dateComponents(set, from: now)
        let startDate = calendar.date(from: components)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate!)
        return (startDate!, endDate!)
    }
    
    static func TimeStamp(time: Date) -> Int64 {
        
        let dateStamp = time.timeIntervalSince1970
        
        let dateSt: Int64 = Int64(dateStamp)
        
        return dateSt
    
    }
    
    static func StampTime(Stamp: Int64) -> Date {
    
        let timeSta:TimeInterval = TimeInterval(Stamp)
        let date = NSDate(timeIntervalSince1970: timeSta)
        
        return date as Date
        
    }
    
}

