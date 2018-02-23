//
//  Logger.swift
//  llitgi
//
//  Created by Xavi Moll on 25/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation
import Fabric
import Crashlytics

final class Logger {
    
    private init() {}
    
    enum LogEvent {
        case debug
        case warning
        case error
        
        fileprivate var emoji: String {
            switch self {
            case .debug :
                return "💬"
            case .warning:
                return "⚠️"
            case .error:
                return "❌"
            }
        }
    }
    
    class func configureFabric() {
        Fabric.with([Crashlytics.self, Answers.self])
        #if DEVELOPMENT
            Fabric.sharedSDK().debug = true
        #endif
    }
    
    class func log(_ message: String, event: LogEvent = .debug, fileName: String = #file, line: Int = #line, funcName: String = #function) {
        debugPrint("[\(event.emoji)][\(sourceFileName(filePath: fileName))]:\(line) \(funcName): \(message)")
        if event == .error {
            #if DEVELOPMENT
            #else
                Answers.logCustomEvent(withName: message, customAttributes: ["Filenane": sourceFileName, "Line": line, "Function": funcName])
            #endif
        }
    }
    
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.last ?? ""
    }
}
