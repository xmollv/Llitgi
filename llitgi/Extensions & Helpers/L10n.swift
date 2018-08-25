//
//  L10n.swift
//  llitgi
//
//  Created by Xavi Moll on 02/05/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation

enum L10n {
    
    enum General {
        static let dismiss = NSLocalizedString("General.dismiss", comment: "")
        static let retry = NSLocalizedString("General.retry", comment: "")
        static let search = NSLocalizedString("General.search", comment: "")
        static let logout = NSLocalizedString("General.logout", comment: "")
        static let errorTitle = NSLocalizedString("General.errorTitle", comment: "")
        static let errorDescription = NSLocalizedString("General.errorDescription", comment: "")
        static let pocketError = NSLocalizedString("General.errorPocket", comment: "")
    }
    
    enum Add {
        static let invalidPasteboard = NSLocalizedString("Add.invalidPasteboard", comment: "")
    }
    
    enum Titles {
        static let all = NSLocalizedString("Titles.all", comment: "")
        static let myList = NSLocalizedString("Titles.myList", comment: "")
        static let favorites = NSLocalizedString("Titles.favorites", comment: "")
        static let archive = NSLocalizedString("Titles.archive", comment: "")
        static let settings = NSLocalizedString("Titles.settings", comment: "")
    }
    
    enum Onboarding {
        static let title = NSLocalizedString("Onboarding.title", comment: "")
        static let offlineTitle = NSLocalizedString("Onboarding.offlineTitle", comment: "")
        static let offlineDescription = NSLocalizedString("Onboarding.offlineDescription", comment: "")
        static let syncTitle = NSLocalizedString("Onboarding.syncTitle", comment: "")
        static let syncDescription = NSLocalizedString("Onboarding.syncDescription", comment: "")
        static let minimalistTitle = NSLocalizedString("Onboarding.minimalistTitle", comment: "")
        static let minimalistDescription = NSLocalizedString("Onboarding.minimalistDescription", comment: "")
        static let button = NSLocalizedString("Onboarding.action", comment: "")
    }
    
    enum Sync {
        static let title = NSLocalizedString("Sync.title", comment: "")
        static let explanation = NSLocalizedString("Sync.explanation", comment: "")
        static let successTitle = NSLocalizedString("Sync.success", comment: "")
        static let successExplanation = NSLocalizedString("Sync.successExplanation", comment: "")
        static let successButton = NSLocalizedString("Sync.successButton", comment: "")
    }
    
    enum Actions {
        static let favorite = NSLocalizedString("Actions.favorite", comment: "")
        static let unfavorite = NSLocalizedString("Actions.unfavorite", comment: "")
        static let archive = NSLocalizedString("Actions.archive", comment: "")
        static let unarchive = NSLocalizedString("Actions.unarchive", comment: "")
        static let delete = NSLocalizedString("Actions.delete", comment: "")
    }
    
    enum Settings {
        static let badgeCountTitle = NSLocalizedString("Settings.badgecount", comment: "")
        static let badgeCountExplanation = NSLocalizedString("Settings.badgeExplanation", comment: "")
        static let safariOpenerTitle = NSLocalizedString("Settings.safariOpenerTitle", comment: "")
        static let safariOpenerDescription = NSLocalizedString("Settings.safariOpenerExplanation", comment: "")
        static let safariReaderTitle = NSLocalizedString("Settings.safariReaderTitle", comment: "")
        static let safariReaderDescription = NSLocalizedString("Settings.safariReaderExplanation", comment: "")
        static let themeTitle = NSLocalizedString("Settings.themeTitle", comment: "")
        static let lightTheme = NSLocalizedString("Settings.lightTheme", comment: "")
        static let darkTheme = NSLocalizedString("Settings.darkTheme", comment: "")
        static let blackTheme = NSLocalizedString("Settings.blackTheme", comment: "")
        static let github = NSLocalizedString("Settings.github", comment: "")
        static let twitter = NSLocalizedString("Settings.twitter", comment: "")
        static let email = NSLocalizedString("Settings.email", comment: "")
        static let buildVersion = NSLocalizedString("Settings.buildVersion", comment: "")
    }
    
    enum ShareExtension {
        static let saving = NSLocalizedString("ShareExtension.saving", comment: "")
    }
}
