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
        static let dismiss = NSLocalizedString("dismiss", comment: "")
        static let retry = NSLocalizedString("retry", comment: "")
        static let search = NSLocalizedString("search", comment: "")
        static let logout = NSLocalizedString("logout", comment: "")
        static let errorTitle = NSLocalizedString("error_title", comment: "")
        static let errorDescription = NSLocalizedString("error_description", comment: "")
        static let pocketError = NSLocalizedString("error_pocket", comment: "")
    }
    
    enum Add {
        static let invalidPasteboard = NSLocalizedString("pasteboard_not_valid", comment: "")
    }
    
    enum Titles {
        static let all = NSLocalizedString("all", comment: "")
        static let myList = NSLocalizedString("my_list", comment: "")
        static let favorites = NSLocalizedString("favorites", comment: "")
        static let archive = NSLocalizedString("archive", comment: "")
        static let settings = NSLocalizedString("settings", comment: "")
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
        static let title = NSLocalizedString("sync_title", comment: "")
        static let explanation = NSLocalizedString("sync_explanation", comment: "")
        static let successTitle = NSLocalizedString("sucess", comment: "")
        static let successExplanation = NSLocalizedString("sync_explanation_success", comment: "")
        static let successButton = NSLocalizedString("lets_go", comment: "")
    }
    
    enum ListEmptyStates {
        static let allTitle = NSLocalizedString("no_results_all_title", comment: "")
        static let allSubtitle = NSLocalizedString("no_results_all_subtitle", comment: "")
        static let myListTitle = NSLocalizedString("no_results_myList_title", comment: "")
        static let myListSubtitle = NSLocalizedString("no_results_myList_subtitle", comment: "")
        static let favoritesTitle = NSLocalizedString("no_results", comment: "")
        static let favoritesSubtitle = NSLocalizedString("no_results_favorites_subtitle", comment: "")
        static let archiveTitle = NSLocalizedString("no_results", comment: "")
        static let archiveSubtitle = NSLocalizedString("no_results_archive_subtitle", comment: "")
        static let searchTitle = NSLocalizedString("no_results", comment: "")
        static let searchSubtitle = NSLocalizedString("no_results_search", comment: "")
    }
    
    enum Actions {
        static let favorite = NSLocalizedString("favorite", comment: "")
        static let unfavorite = NSLocalizedString("unfavorite", comment: "")
        static let archive = NSLocalizedString("to_archive", comment: "")
        static let unarchive = NSLocalizedString("unarchive", comment: "")
        static let delete = NSLocalizedString("delete", comment: "")
    }
    
    enum Settings {
        static let badgeCountTitle = NSLocalizedString("badge_count", comment: "")
        static let badgeCountExplanation = NSLocalizedString("badge_explanation", comment: "")
        static let safariOpenerTitle = NSLocalizedString("open_links_safari", comment: "")
        static let safariOpenerDescription = NSLocalizedString("safari_open_explanation", comment: "")
        static let safariReaderTitle = NSLocalizedString("safari_reader_mode", comment: "")
        static let safariReaderDescription = NSLocalizedString("safari_reader_mode_explanation", comment: "")
        static let github = NSLocalizedString("Settings.github", comment: "")
        static let twitter = NSLocalizedString("Settings.twitter", comment: "")
        static let email = NSLocalizedString("email", comment: "")
        static let buildVersion = NSLocalizedString("build_version", comment: "")
    }
    
    enum ShareExtension {
        static let saving = NSLocalizedString("saving_to_llitgi", comment: "")
    }
}
