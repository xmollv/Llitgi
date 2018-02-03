//
//  Dependencies.swift
//  litgi
//
//  Created by Xavi Moll on 12/01/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation

class Dependencies {
    
    let dataProvider: DataProvider
    let syncManager: SyncManager
    let userPreferences: UserPreferences
    
    init(dataProvider: DataProvider, syncManager: SyncManager, userPreferences: UserPreferences) {
        self.dataProvider = dataProvider
        self.syncManager = syncManager
        self.userPreferences = userPreferences
    }
}
