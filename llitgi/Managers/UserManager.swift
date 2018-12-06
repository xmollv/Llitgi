//
//  PreferencesManager.swift
//  llitgi
//
//  Created by Xavi Moll on 12/01/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

enum SafariOpener: String {
    case safariViewController
    case safari
}

protocol UserManager: class {
    var isLoggedIn: Bool { get }
    var openLinksWith: SafariOpener { get set }
    var openReaderMode: Bool { get set }
    var userHasEnabledNotifications: Bool { get }
    
    func enableBadge(shouldEnable: Bool, then: @escaping (Bool)->())
}

class UserPreferencesManager: UserManager {
    
    //MARK: Public properties
    var isLoggedIn: Bool {
        if let _ = LlitgiUserDefaults.shared.string(forKey: kAccesToken) {
            return true
        } else {
            return false
        }
    }
    
    var userHasEnabledNotifications: Bool {
        get { return LlitgiUserDefaults.shared.bool(forKey: kEnabledNotifications) }
        set { LlitgiUserDefaults.shared.set(newValue, forKey: kEnabledNotifications) }
    }
    
    var openLinksWith: SafariOpener {
        get {
            let savedValue = LlitgiUserDefaults.shared.string(forKey: kSafariOpener) ?? ""
            return SafariOpener(rawValue: savedValue) ?? .safariViewController
        }
        set { LlitgiUserDefaults.shared.set(newValue.rawValue, forKey: kSafariOpener) }
    }
    
    var openReaderMode: Bool {
        get { return LlitgiUserDefaults.shared.bool(forKey: kReaderMode) }
        set { LlitgiUserDefaults.shared.set(newValue, forKey: kReaderMode) }
    }
    
    func enableBadge(shouldEnable: Bool, then: @escaping (Bool) -> ()) {
        if shouldEnable {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge], completionHandler: { [weak self] (granted, error) in
                DispatchQueue.main.async {
                    self?.userHasEnabledNotifications = granted
                    then(granted)
                }
            })
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.userHasEnabledNotifications = false
                then(false)
            }
        }
    }
}
