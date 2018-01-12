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
    
    init(factory: ViewControllerFactory, dataProvider: DataProvider) {
        self.factory = factory
        self.dataProvider = dataProvider
    }
}
