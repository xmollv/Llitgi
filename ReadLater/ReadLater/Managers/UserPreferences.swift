//
//  UserPreferences.swift
//  ReadLater
//
//  Created by Xavi Moll on 12/01/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation

enum SafariOpener: String {
    case safariViewController
    case safari
}

protocol UserPreferences: class {
    var openLinksWith: SafariOpener { get set }
}

class UserPreferencesManager: UserPreferences {
    
    var openLinksWith: SafariOpener {
        get {
            let savedValue = UserDefaults.standard.string(forKey: "safariOpener") ?? ""
            return SafariOpener(rawValue: savedValue) ?? .safariViewController
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "safariOpener")
        }
    }
    
}
