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
        do {
            if let url = Bundle.main.url(forResource: "fabric.apikey", withExtension: nil) {
                let key = try String(contentsOf: url, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
                Fabric.with([Crashlytics.start(withAPIKey: key), Answers.self])
            }
        } catch {
            NSLog("Could not retrieve Crashlytics API key. Check that fabric.apikey exists, contains your Crashlytics API key, and is a member of the target")
        }
    }
    
    class func log(_ message: String, event: LogEvent = .debug, fileName: String = #file, line: Int = #line, funcName: String = #function) {
        debugPrint("[\(event.emoji)][\(sourceFileName(filePath: fileName))]:\(line) \(funcName): \(message)")
        if event == .error {
            Answers.logCustomEvent(withName: message, customAttributes: ["Source": "\(sourceFileName(filePath: fileName)):\(funcName)"])
        }
    }
    
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.last ?? ""
    }
}
