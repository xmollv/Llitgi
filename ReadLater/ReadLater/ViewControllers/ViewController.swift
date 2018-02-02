//
//  ViewController.swift
//  ReadLater
//
//  Created by Xavi Moll on 24/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let factory: ViewControllerFactory
    let dataProvider: DataProvider
    let userPreferences: UserPreferences
    
    required init(factory: ViewControllerFactory, dependencies: Dependencies) {
        self.factory = factory
        self.dataProvider = dependencies.dataProvider
        self.userPreferences = dependencies.userPreferences
        super.init(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("Dependency Injection required")
    }

}
