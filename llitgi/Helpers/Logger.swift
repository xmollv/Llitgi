//
//  Logger.swift
//  llitgi
//
//  Created by Xavi Moll on 25/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation

final class Logger {
    
    private init() {}
    
    enum LogEvent: String {
        case debug = "[💬]"
        case warning = "[⚠️]"
        case error = "[🔥]"
    }
    
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    static func log(_ message: String, event: LogEvent = .debug, fileName: String = #file, line: Int = #line, funcName: String = #function) {
        #if DEBUG
            print("\(Date().toString()) - \(event.rawValue)[\(sourceFileName(filePath: fileName))]:\(line) \(funcName) -> \(message)")
        #endif
    }
    
    private static func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.last ?? ""
    }
}

private extension Date {
    func toString() -> String {
        return Logger.dateFormatter.string(from: self)
    }
}
