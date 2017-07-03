//
//  Date+Utils.swift
//  UUChat
//
//  Created by jiang.duan on 2017/3/1.
//  Copyright © 2017年 jiang.duan. All rights reserved.
//

import Foundation

extension Date {
    
    static func daysOffBetween(startDate: Date, endDate: Date) -> Int {
        let gregorian = Calendar(identifier: .gregorian)
        var set = Set<Calendar.Component>()
        set.insert(Calendar.Component.day)
        let comps = gregorian.dateComponents(set, from: startDate, to: endDate)
        return comps.day!
    }
    
    static func today() -> (startDate: Date, endDate: Date) {
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


// MARK: - Date component
extension Date {

    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    var second: Int {
        return Calendar.current.component(.second, from: self)
    }
    
    enum WeekType: Int {
        case sunday = 1
        case monday = 2
        case tuesday = 3
        case wednesday = 4
        case thursday = 5
        case friday = 6
        case saturday = 7
    }
    
    var weekday: WeekType {
        return WeekType(rawValue: Calendar.current.component(.weekday, from: self))!
    }
}


// MARK: - Date string
extension Date {
    
    var stringTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    var stringMonthDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        return formatter.string(from: self)
    }
    
    var stringYearMonthDayHourMinuteSecond: String {
        let formatter = DateFormatter()
        formatter.dateFormat = Date.timestampFormatString
        return formatter.string(from: self)
    }
    
    var stringYearMonthDayHourMinute: String {
        let formatter = DateFormatter()
        formatter.dateFormat = Date.timestampFormatString
        return formatter.string(from: self)
    }
    
    var stringYearMonthDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = Date.dateFormatString
        return formatter.string(from: self)
    }
    
    enum CompareToday: String {
        case today = "Today"
        case tomorrow = "Tomorrow"
        case yesterday = "Yesterday"
    }
    
    var stringYearMonthDayCompareToday: CompareToday? {
        let chaDay = self.daysBetweenCurrentDateAndDate
        if chaDay == 0 {
            return .today
        } else if chaDay == 1 {
            return .tomorrow
        } else if chaDay == -1 {
            return .yesterday
        }
        return nil
    }
}

extension Date.CompareToday: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .today:
            return  R.string.localizable.id_today()
        case .tomorrow:
            return R.string.localizable.id_tomorrow()
        case .yesterday:
            return R.string.localizable.id_yesterday()
        }
    }
}

// MARK: - Relative Dates
extension Date {
    
    var dateTimeZero: Date {
        var set = Set<Calendar.Component>()
        set.insert(Calendar.Component.year)
        set.insert(Calendar.Component.month)
        set.insert(Calendar.Component.day)
        let comps = Calendar.current.dateComponents(set, from: self)
        return Calendar.current.date(from: comps)!
    }
    
    var daysBetweenCurrentDateAndDate: Int {
        //只取年月日比较
        let dateSelf = self.dateTimeZero
        let timeInterval = dateSelf.timeIntervalSince1970
        let dateNow = Date().dateTimeZero
        let timeIntervalNow = dateNow.timeIntervalSince1970
        
        let cha = timeInterval - timeIntervalNow
        let chaDay = cha / 86400.0
        return Int(chaDay)
    }
}

// MARK: - Date formate
extension Date {
    
    
    static var dateFormatString: String {
        return "yyyy-MM-dd"
    }
    
    static var timeFormatString: String {
        return "HH:mm:ss"
    }
    
    static var timestampFormatString: String {
        return "yyyy-MM-dd HH:mm:ss";
    }
    
    static var timestampFormatStringSubSeconds: String {
        return "yyyy-MM-dd HH:mm";
    }
}
