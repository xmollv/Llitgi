//
//  Dependencies.swift
//  llitgi
//
//  Created by Xavi Moll on 12/01/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation

class Dependencies {
    
    let dataProvider: DataProvider
    let syncManager: SyncManager
    let userPreferences: PreferencesManager
    
    init(dataProvider: DataProvider, syncManager: SyncManager, userPreferences: PreferencesManager) {
        self.dataProvider = dataProvider
        self.syncManager = syncManager
        self.userPreferences = userPreferences
    }
}
