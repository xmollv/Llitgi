//
//  Dependencies.swift
//  ReadLater
//
//  Created by Xavi Moll on 12/01/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation

class Dependencies {
    
    let factory: ViewControllerFactory
    let dataProvider: DataProvider
    let userPreferences: UserPreferences
    
    init(factory: ViewControllerFactory,
         dataProvider: DataProvider,
         userPreferences: UserPreferences) {
        self.factory = factory
        self.dataProvider = dataProvider
        self.userPreferences = userPreferences
    }
}
