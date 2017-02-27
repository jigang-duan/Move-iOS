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
}
