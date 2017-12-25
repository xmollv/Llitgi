//
//  ViewControllerFactory.swift
//  ReadLater
//
//  Created by Xavi Moll on 24/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import Foundation

final class ViewControllerFactory {
    
    private let dataProvider: DataProvider
    
    init(dataProvider: DataProvider) {
        self.dataProvider = dataProvider
    }
    
    func instantiate<T: ViewController>() -> T {
        let viewController = T(factory: self, dataProvider: self.dataProvider)
        return viewController
    }
}
