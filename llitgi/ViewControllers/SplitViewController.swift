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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupMainFlow() {
        let master = TabBarController(factory: factory)
        master.setupMainFlow()
        var viewControllers : [UIViewController] = [master]
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            let emptyDetail = factory.instantiateEmptyDetail()
            viewControllers.append(emptyDetail)
        }
        self.viewControllers = viewControllers
        preferredDisplayMode = .allVisible
    }
}


extension SplitViewController: SafariShowing {
    func show(safariViewController: SFSafariViewController) {
        safariViewController.delegate = self
        showDetailViewController(safariViewController, sender: self)
    }
}

extension SplitViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            let emptyDetail = factory.instantiateEmptyDetail()
            showDetailViewController(emptyDetail, sender: self)
		}
	}
}

