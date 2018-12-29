//
//  BadgeManager.swift
//  llitgi
//
//  Created by Xavi Moll on 06/12/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation
import UIKit

extension NSNotification.Name {
    static let badgeChanged = Notification.Name("badgeChanged")
}

final class BadgeManager: NSObject {
    
    private let notifier: CoreDataNotifier<CoreDataItem>
    private let userManager: UserManager
    
    init(notifier: CoreDataNotifier<CoreDataItem>, userManager: UserManager) {
        self.userManager = userManager
        self.notifier = notifier
        super.init()
        self.notifier.delegate = self
        self.notifier.startNotifying()
        self.updateBadgeCount()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateBadgeCount), name: .badgeChanged, object: nil)
    }
    
    @objc
    private func updateBadgeCount() {
        if self.userManager.userHasEnabledNotifications {
            let amount = self.notifier.numberOfElements(inSection: 0)
            UIApplication.shared.applicationIconBadgeNumber = amount
            Logger.log("Update badge to: \(amount)")
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
            Logger.log("Removed badge")
        }
    }
    
}

extension BadgeManager: CoreDataNotifierDelegate {
    func willChangeContent() {}
    
    func didChangeSection(_ change: CoreDataNotifierSectionChange) {}
    
    func didChangeObject(_ change: CoreDataNotifierChange) {}
    
    func endChangingContent() {
        self.updateBadgeCount()
    }
    
    func startNotifyingFailed(with error: Error) {}
}
