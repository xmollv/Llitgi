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
    
    func setupMainFlow(shouldEnableOverlayMode: Bool) {
        let master = TabBarController(factory: factory)
        master.setupMainFlow()
        let emptyDetail = factory.instantiateEmptyDetail()
        self.viewControllers = [master, emptyDetail]
        if (shouldEnableOverlayMode) {
            preferredDisplayMode = .primaryOverlay
        } else {
            preferredDisplayMode = .allVisible
        }
    }
}

extension SplitViewController: SafariShowing {
    func show(safariViewController: SFSafariViewController) {
        safariViewController.delegate = self
        showDetailViewController(safariViewController, sender: self)
    }
}

extension SplitViewController: OverlayDisplaying {
    func overlayDisplayMode(isEnabled: Bool) {
        if (isEnabled) {
            preferredDisplayMode = .primaryOverlay
        } else {
            preferredDisplayMode = .allVisible
        }
    }
}

extension SplitViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        let emptyDetail = factory.instantiateEmptyDetail()
        showDetailViewController(emptyDetail, sender: self)
    }
}

