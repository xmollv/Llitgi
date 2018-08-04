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
        self.viewControllers = [master]
        preferredDisplayMode = .allVisible
    }
}

extension SplitViewController: SafariShowing {
    func show(safariViewController: SFSafariViewController) {
        showDetailViewController(safariViewController, sender: self)
    }
}

extension SplitViewController: OverlayDisplaying {
    func overlayDisplayMode(shouldBeSet: Bool) {
        DispatchQueue.main.async {
            if shouldBeSet {
                self.preferredDisplayMode = .primaryOverlay
                print("Setting preferredDisplayMode to primaryOverlay")
            } else {
                self.preferredDisplayMode = .allVisible
                print("Setting preferredDisplayMode to allVisible")
            }
        }
    }
    
    func isOverlayDisplayModeSet() -> Bool {
        return preferredDisplayMode == .primaryOverlay
    }
    
}
