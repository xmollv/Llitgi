//
//  UserPreferences.swift
//  ReadLater
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

protocol BadgeDelegate: class {
    func displayBadgeEnabled()
}

protocol UserPreferences: class {
    var openLinksWith: SafariOpener { get set }
    
    weak var badgeDelegate: BadgeDelegate? { get set }
    var userHasEnabledNotifications: Bool { get set }
    func enableBadge(shouldEnable: Bool, then: @escaping (Bool)->())
    func displayBadge(with: Int)
}

class UserPreferencesManager: UserPreferences {
    
    weak var badgeDelegate: BadgeDelegate? = nil
    
    var userHasEnabledNotifications: Bool {
        get { return UserDefaults.standard.bool(forKey: "enabledNotifications") }
        set {
            UserDefaults.standard.set(newValue, forKey: "enabledNotifications")
            if newValue == true {
                self.badgeDelegate?.displayBadgeEnabled()
            }
        }
    }
    
    var openLinksWith: SafariOpener {
        get {
            let savedValue = UserDefaults.standard.string(forKey: "safariOpener") ?? ""
            return SafariOpener(rawValue: savedValue) ?? .safariViewController
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "safariOpener") }
    }
    
    func enableBadge(shouldEnable: Bool, then: @escaping (Bool) -> ()) {
        if shouldEnable {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge], completionHandler: { (granted, error) in
                DispatchQueue.main.async {
                    self.userHasEnabledNotifications = granted
                    then(granted)
                }
            })
        } else {
            DispatchQueue.main.async {
                self.userHasEnabledNotifications = false
                UIApplication.shared.applicationIconBadgeNumber = 0
                then(false)
            }
        }
    }
    
    func displayBadge(with numberOfElements: Int) {
        if self.userHasEnabledNotifications {
            UIApplication.shared.applicationIconBadgeNumber = numberOfElements
        }
    }
    
}
