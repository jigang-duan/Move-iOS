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

    static func today18() -> Date {
        
      let dformatter = DateFormatter()
      dformatter.dateFormat = "yyyy-MM-dd HH:mm"
      var todayString = dformatter.string(from: Date.today().startDate)
      
      todayString = todayString.replacingOccurrences(of: "00:00", with: "18:00")
      
       return dformatter.date(from: todayString)!
    }
    
    static func todayy() -> String {
        
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy-MM-dd"
        let todayString: String = dformatter.string(from: Date.today().startDate)
        
        return todayString
    }
    
    static func today18half() -> Date {
        
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy-MM-dd HH:mm"
        var todayString = dformatter.string(from: Date.today().startDate)
        
        todayString = todayString.replacingOccurrences(of: "00:00", with: "18:30")
        
        return dformatter.date(from: todayString)!
    }
    
    
    static func dateTostringHHmm(date: Date?) -> String {
        
        let dformatter = DateFormatter()
        dformatter.timeZone = TimeZone(secondsFromGMT: 0)
        dformatter.dateFormat = "HH:mm"
        return dformatter.string(from: date ?? Date(timeIntervalSince1970: 0))
        
    }
    static func dateTostringyyMMdd(date: Date?) -> String {
        
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dformatter.string(from: date ?? Date(timeIntervalSince1970: 0))
        
    }
    static func dateTostringyyMMddd(date: Date?) -> String {
        
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy-MM-dd"
        return dformatter.string(from: date ?? Date(timeIntervalSince1970: 0))
        
    }
    
    //string To Date add by gaoweixin at 2017.05.31
    static func stringToDateyyMMddd(dateString: String?) -> Date {
        
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy-MM-dd"
        return dformatter.date(from: dateString ?? "")!
    }
    
    static func dateTostringMMdd(date: Date?) -> String {
        
        let dformatter = DateFormatter()
        dformatter.dateFormat = "HH:mm"
        return dformatter.string(from: date ?? Date(timeIntervalSince1970: 0))
        
    }
    static func dateTostringMMddyy(date: Date?) -> String {
        
        let dformatter = DateFormatter()
        dformatter.dateFormat = "MM-dd-yyyy HH:mm"
        return dformatter.string(from: date ?? Date(timeIntervalSince1970: 0))
        
    }
    
    static func zoneDay() -> (startDate: Date, endDate: Date) {
        let now = Date(timeIntervalSince1970: 0)
        return (now,now.addingTimeInterval(DateUtility.SEC_DAY))
    }
    
    static func zone7hour() -> Date {
        return DateUtility.zoneDay().startDate.addingTimeInterval(25200)
    }
    static func zone8hour() -> Date {
        return DateUtility.zoneDay().startDate.addingTimeInterval(28800)
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
    //日期处理
    //星期获取
    static func getWeekDay(date: Date) ->Int {
        
        let calendar = Calendar.current
        
        let dateComponents = calendar.dateComponents([.year,.month,.day, .weekday, .hour, .minute,.second], from: date)
        
        return dateComponents.weekday!
        
    }
    //日 获取
    static func getDay(date: Date) ->Int {
        
        let calendar = Calendar.current
        
        //这里注意 swift要用[,]这样方式写
        
        let dateComponents = calendar.dateComponents([.year,.month,.day, .weekday, .hour, .minute,.second], from: date)
        
        return dateComponents.day!
        
    }
    
    // Default Date formatter
    static var defaultDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }()
    
    static var shortDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    static var defaultYearMonthDayFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    
    static var defaultHourMinuteSecondFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }()
}


extension Date {
    
    var stringDefaultDescription: String {
        return DateUtility.defaultDateFormatter.string(from: self)
    }
    
    var stringScreenDescription: String {
//        if UIScreen.main.isIPhone5OrLess {
//            return DateUtility.shortDateFormatter.string(from: self)
//        } else {
//            return DateUtility.defaultDateFormatter.string(from: self)
//        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd HH:mm"
        return dateFormatter.string(from: self)
    }
    
    var stringDefaultYearMonthDay: String {
        return DateUtility.defaultYearMonthDayFormatter.string(from: self)
    }
    
    var stringDefaultHourMinuteSecond: String {
        return DateUtility.defaultHourMinuteSecondFormatter.string(from: self)
    }
}

extension Date {
    
    var isWithin1Hour: Bool {
        return self.isWithin(1.0.hour)
    }
    
    var isWithin2Hour: Bool {
        return self.isWithin(2.0.hour)
    }
    
    private func isWithin(_ interval :TimeInterval) -> Bool {
        return Date(timeInterval: interval, since: self).compare(Date()) == .orderedDescending
    }
}


fileprivate extension TimeInterval {
    
    var minute: TimeInterval {
        return 60.0 * self
    }
    
    var hour: TimeInterval {
        return 3600.0 * self
    }
}
