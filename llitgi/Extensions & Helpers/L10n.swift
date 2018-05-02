//
//  L10n.swift
//  llitgi
//
//  Created by Xavi Moll on 02/05/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation

struct L10n {
    
    struct General {
        static let dismiss = NSLocalizedString("dismiss", comment: "")
        static let retry = NSLocalizedString("retry", comment: "")
        static let search = NSLocalizedString("search", comment: "")
        static let logout = NSLocalizedString("logout", comment: "")
        static let errorTitle = NSLocalizedString("error_title", comment: "")
        static let pocketError = NSLocalizedString("error_pocket", comment: "")
    }
    
    struct Add {
        static let invalidPasteboard = NSLocalizedString("pasteboard_not_valid", comment: "")
    }
    
    struct Titles {
        static let myList = NSLocalizedString("my_list", comment: "")
        static let favorites = NSLocalizedString("favorites", comment: "")
        static let archive = NSLocalizedString("archive", comment: "")
        static let settings = NSLocalizedString("settings", comment: "")
    }
    
    struct Onboarding {
        static let title = NSLocalizedString("onboarding_title", comment: "")
        static let description = NSLocalizedString("onboarding", comment: "")
        static let button = NSLocalizedString("lets_do_it", comment: "")
        static let authError = NSLocalizedString("auth_error", comment: "")
    }
    
    struct Sync {
        static let title = NSLocalizedString("sync_title", comment: "")
        static let explanation = NSLocalizedString("sync_explanation", comment: "")
        static let successTitle = NSLocalizedString("sucess", comment: "")
        static let successExplanation = NSLocalizedString("sync_explanation_success", comment: "")
        static let successButton = NSLocalizedString("lets_go", comment: "")
    }
    
    struct ListEmptyStates {
        static let myListTitle = NSLocalizedString("no_results_myList_title", comment: "")
        static let myListSubtitle = NSLocalizedString("no_results_myList_subtitle", comment: "")
        static let favoritesTitle = NSLocalizedString("no_results", comment: "")
        static let favoritesSubtitle = NSLocalizedString("no_results_favorites_subtitle", comment: "")
        static let archiveTitle = NSLocalizedString("no_results", comment: "")
        static let archiveSubtitle = NSLocalizedString("no_results_archive_subtitle", comment: "")
        static let searchTitle = NSLocalizedString("no_results", comment: "")
        static let searchSubtitle = NSLocalizedString("no_results_search", comment: "")
    }
    
    struct Actions {
        static let favorite = NSLocalizedString("favorite", comment: "")
        static let unfavorite = NSLocalizedString("unfavorite", comment: "")
        static let archive = NSLocalizedString("to_archive", comment: "")
        static let unarchive = NSLocalizedString("unarchive", comment: "")
        static let delete = NSLocalizedString("delete", comment: "")
    }
    
    struct Settings {
        static let badgeCountTitle = NSLocalizedString("badge_count", comment: "")
        static let badgeCountExplanation = NSLocalizedString("badge_explanation", comment: "")
        static let safariOpenerTitle = NSLocalizedString("open_links_safari", comment: "")
        static let safariOpenerDescription = NSLocalizedString("safari_open_explanation", comment: "")
        static let safariReaderTitle = NSLocalizedString("safari_reader_mode", comment: "")
        static let safariReaderDescription = NSLocalizedString("safari_reader_mode_explanation", comment: "")
        static let credits = NSLocalizedString("credits", comment: "")
        static let email = NSLocalizedString("email", comment: "")
        static let buildVersion = NSLocalizedString("build_version", comment: "")
    }
    
    struct ShareExtension {
        static let saving = NSLocalizedString("saving_to_llitgi", comment: "")
    }
}
