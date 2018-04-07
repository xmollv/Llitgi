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
    let userPreferences: PreferencesManager
    
    init(dataProvider: DataProvider, userPreferences: PreferencesManager) {
        self.dataProvider = dataProvider
        self.userPreferences = userPreferences
    }
}
