//
//  SplitViewController.swift
//  llitgi
//
//  Created by Adrian Tineo on 24.07.18.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

class SplitViewController: UISplitViewController {
    
    //MARK: Private properties
    private let factory: ViewControllerFactory
    
    //MARK: Lifecycle
    init(factory: ViewControllerFactory) {
        self.factory = factory
        super.init(nibName: nil, bundle: nil)
        preferredDisplayMode = .allVisible
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupMainFlow() {
        let master = TabBarController(factory: factory)
        master.setupMainFlow()
        self.viewControllers = [master]
    }
}


extension SplitViewController: SafariShowing {
    func show(safariViewController: SFSafariViewController) {
        showDetailViewController(safariViewController, sender: self)
    }
}
