//
//  SettingsViewController.swift
//  ReadLater
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
        //TODO: Missing implementation
        // Delete contents of core data
        // Delete tokens saved on user defaults
        // Delete lasSync value stored on user defaults
    }
    
    //MARK:- Private methods
    private func setupLocalizedStrings() {
        self.titleLabel.text = NSLocalizedString("Settings", comment: "")
        self.badgeCountLabel.text = NSLocalizedString("Show app badge count", comment: "")
        self.badgeCountExplanationLabel.text = NSLocalizedString("This will display a badge count on the app icon on your homescreen with the number of elements on your list.", comment: "")
        self.safariOpenerLabel.text = NSLocalizedString("Open links using Safari", comment: "")
        self.safariOpenerExplanationLabel.text = NSLocalizedString("Enabling this option will open Safari with the tapped link instead of opening the link in the app.", comment: "")
        self.logoutButton.setTitle(NSLocalizedString("Logout", comment: ""), for: .normal)
    }

}
