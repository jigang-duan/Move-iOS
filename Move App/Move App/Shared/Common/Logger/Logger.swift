//
//  Logger.swift
//  LinkApp
//
//  Created by Jiang Duan on 17/1/3.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import SwiftyBeaver


class Log {

    let log = SwiftyBeaver.self
    
    // Share instance
    static var shareInstance = Log()
    
    init() {
        
        // Log console
        let console = ConsoleDestination()  // log to Xcode Console
        self.log.addDestination(console)
        
        // Log File
        if Configure.Logger.toFile {
            let file = FileDestination()  // log to default swiftybeaver.log file
            self.log.addDestination(file)
        }
    }
    
    // MARK:
    // MARK: Public
    
    /// 记录错误日志
    ///
    /// - Parameters:
    ///   - error: 日志信息
    ///   - file: 记录日志的文件
    ///   - function: 记录日志的函数名
    ///   - line: 记录日志的行号
    func error(_ error: Any, file: String, function: String, line: Int) {
        self.log.error(error, file, function, line: line)
    }
    
    /// 记录高级日志
    ///
    /// - Parameters:
    ///   - warning: 日志信息
    ///   - file: 记录日志的文件
    ///   - function: 记录日志的函数名
    ///   - line: 记录日志的行号
    func warning(_ warning: Any, _ file: String, _ function: String, _ line: Int) {
        self.log.warning(warning, file, function, line: line)
    }
    
    /// 记录调试日志
    ///
    /// - Parameters:
    ///   - warning: 日志信息
    ///   - file: 记录日志的文件
    ///   - function: 记录日志的函数名
    ///   - line: 记录日志的行号
    func debug(_ debug: Any, _ file: String, _ function: String, _ line: Int) {
        self.log.debug(debug, file, function, line: line)
    }
    
    /// 记录信息日志
    ///
    /// - Parameters:
    ///   - warning: 日志信息
    ///   - file: 记录日志的文件
    ///   - function: 记录日志的函数名
    ///   - line: 记录日志的行号
    func info(_ info: Any, _ file: String, _ function: String, _ line: Int) {
        self.log.info(info, file, function, line: line)
    }
    
    /// 记录详细的日志
    ///
    /// - Parameters:
    ///   - warning: 日志信息
    ///   - file: 记录日志的文件
    ///   - function: 记录日志的函数名
    ///   - line: 记录日志的行号
    func verbose(_ verbose: Any, _ file: String, _ function: String, _ line: Int) {
        self.log.verbose(verbose, file, function, line: line)
    }
}


// MARK:
// MARK: Helper
class Logger {
    
    // Helper
    // MARK: Public
    class func initLogger() {
        _ = Log.shareInstance
    }
    
    class func error(_ error:Any, toSlack:Bool = Configure.Logger.toSlack, fileName: String = #file, functionName: String = #function, line: Int = #line) {
        
        // Console
        Log.shareInstance.error(error, file: fileName, function: functionName, line: line)
        
        if toSlack {
            let errorObj = NSError.errorWithMessage(message: "\(error)")
            SlackReporter.shareInstance.reportErrorData(SlackReporterData(error: errorObj, fileName: fileName, functionName: functionName, line: line))
        }
    }
    
    class func warning(_ warning: Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        Log.shareInstance.warning(warning, file, function, line)
    }
    
    class func debug(_ debug: Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        Log.shareInstance.debug(debug, file, function, line)
    }
    
    class func info(_ info: Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        Log.shareInstance.info(info, file, function, line)
    }
    
    class func verbose(_ verbose: Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        Log.shareInstance.verbose(verbose, file, function, line)
    }

}

extension Logger {
    static func reversedLog(seperator: String, terminator: String, items: Any...) {
        guard Configure.App.isDebugJSON else {
            return
        }
        debugPrint("🌐")
        for (index, item) in items.enumerated() {
            Log.shareInstance.debug(item, "Web", "API", index)
        }
    }
}

extension NSError {

    class func errorWithMessage(message: String) -> NSError {
        return NSError(domain: "com.fe.feels", code: 999, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
