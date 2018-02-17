//
//  SettingsViewController.swift
//  llitgi
//
//  Created by Xavi Moll on 07/01/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit

class SettingsViewController: ViewController {

    //MARK:- IBOutlets
    @IBOutlet private var titleLabel: UILabel!

    @IBOutlet private var badgeCountLabel: UILabel!
    @IBOutlet private var badgeCountExplanationLabel: UILabel!
    @IBOutlet private var badgeCountSwitch: UISwitch!
    
    @IBOutlet private var safariOpenerLabel: UILabel!
    @IBOutlet private var safariOpenerExplanationLabel: UILabel!
    @IBOutlet private var safariOpenerSwitch: UISwitch!
    
    @IBOutlet private var logoutButton: UIButton!
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.setupLocalizedStrings()
        self.badgeCount(isEnabled: self.userPreferences.userHasEnabledNotifications)
        self.safariOpenerValue(opener: self.userPreferences.openLinksWith)
    }
    
    //MARK:- IBActions
    private func badgeCount(isEnabled: Bool) {
        switch isEnabled {
        case true:
            self.badgeCountSwitch.setOn(true, animated: false)
        case false:
            self.badgeCountSwitch.setOn(false, animated: false)
        }
    }
    
    @IBAction private func badgeCountValueChanged(_ sender: UISwitch) {
        self.userPreferences.enableBadge(shouldEnable: sender.isOn) { (success) in
            if !success {
                sender.setOn(false, animated: true)
            }
        }
    }
    
    private func safariOpenerValue(opener: SafariOpener) {
        switch opener {
        case .safari:
            self.safariOpenerSwitch.setOn(true, animated: false)
        case .safariViewController:
            self.safariOpenerSwitch.setOn(false, animated: false)
        }
    }
    
    @IBAction private func safariOpenerValueChanged(_ sender: UISwitch) {
        switch sender.isOn {
        case true:
            self.userPreferences.openLinksWith = .safari
        case false:
            self.userPreferences.openLinksWith = .safariViewController
        }
    }
    
    @IBAction private func logoutButtonTapped(_ sender: UIButton) {
        guard let tabBar = self.tabBarController as? TabBarController  else { return }
        self.userPreferences.displayBadge(with: 0)
        self.dataProvider.logout()
        tabBar.setupAuthFlow()
    }
    
    //MARK:- Private methods
    private func setupLocalizedStrings() {
        self.titleLabel.text = NSLocalizedString("settings", comment: "")
        self.badgeCountLabel.text = NSLocalizedString("badge_count", comment: "")
        self.badgeCountExplanationLabel.text = NSLocalizedString("badge_explanation", comment: "")
        self.safariOpenerLabel.text = NSLocalizedString("open_links_safari", comment: "")
        self.safariOpenerExplanationLabel.text = NSLocalizedString("safari_open_explanation", comment: "")
        self.logoutButton.setTitle(NSLocalizedString("logout", comment: ""), for: .normal)
    }

}
