//
//  FlowManager.swift
//  llitgi
//
//  Created by Adrian Tineo on 04.08.18.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation
import UIKit

class FlowManager {
    private let window: UIWindow
    private let dataProvider: DataProvider
    private let userManager: UserManager
    
    init(window: UIWindow, dataProvider: DataProvider, userManager: UserManager) {
        self.window = window
        self.dataProvider = dataProvider
        self.userManager = userManager
    }
    
    func setupAuthFlow() {
        // AuthFlow uses TabBarController
        let viewControllerFactory = ViewControllerFactory(dataProvider: self.dataProvider, userManager: self.userManager, flowManager: self)
        let rootViewController = TabBarController(factory: viewControllerFactory)
        
        rootViewController.setupAuthFlow()
        window.rootViewController = rootViewController
    }
    
    func setupMainFlow() {
        // MainFlow uses SplitViewController
        let viewControllerFactory = ViewControllerFactory(dataProvider: self.dataProvider, userManager: self.userManager, flowManager: self)
        let rootViewController = SplitViewController(factory: viewControllerFactory)
        // Can't be injected at initializer due to circular dependency
        viewControllerFactory.safariShowing = rootViewController
        
        rootViewController.setupMainFlow()
        window.rootViewController = rootViewController
    }
}
