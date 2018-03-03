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
    
    @IBOutlet private var safariReaderModeLabel: UILabel!
    @IBOutlet private var safariReaderModeExplanationLabel: UILabel!
    @IBOutlet private var safariReaderModeSwitch: UISwitch!
    
    @IBOutlet private var logoutButton: UIButton!
    
    @IBOutlet private var creditsLabel: UILabel!
    @IBOutlet private var twitterButton: UIButton!
    @IBOutlet private var emailButton: UIButton!
    @IBOutlet private var buildLabel: UILabel!
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.setupLocalizedStrings()
        self.badgeCount(isEnabled: self.userPreferences.userHasEnabledNotifications)
        self.safariOpenerValue(opener: self.userPreferences.openLinksWith)
        self.establishReaderMode(readerEnabled: self.userPreferences.openReaderMode)
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
    
    private func establishReaderMode(readerEnabled: Bool) {
        self.safariReaderModeSwitch.setOn(readerEnabled, animated: false)
    }
    
    @IBAction func safariReaderModeChanged(_ sender: UISwitch) {
        self.userPreferences.openReaderMode = sender.isOn
    }
    
    @IBAction private func logoutButtonTapped(_ sender: UIButton) {
        guard let tabBar = self.tabBarController as? TabBarController  else { return }
        self.userPreferences.displayBadge(with: 0)
        self.dataProvider.logout()
        tabBar.setupAuthFlow()
    }
    
    @IBAction func twitterButtonTapped(_ sender: UIButton) {
        guard let url = URL(string: "https://twitter.com/xmollv") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func emailButtonTapped(_ sender: UIButton) {
        guard let url = URL(string: "mailto:xmollv@gmail.com") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    //MARK:- Private methods
    private func setupLocalizedStrings() {
        self.titleLabel.text = NSLocalizedString("settings", comment: "")
        self.badgeCountLabel.text = NSLocalizedString("badge_count", comment: "")
        self.badgeCountExplanationLabel.text = NSLocalizedString("badge_explanation", comment: "")
        self.safariOpenerLabel.text = NSLocalizedString("open_links_safari", comment: "")
        self.safariOpenerExplanationLabel.text = NSLocalizedString("safari_open_explanation", comment: "")
        self.safariReaderModeLabel.text = NSLocalizedString("safari_reader_mode", comment: "")
        self.safariReaderModeExplanationLabel.text = NSLocalizedString("safari_reader_mode_explanation", comment: "")
        self.logoutButton.setTitle(NSLocalizedString("logout", comment: ""), for: .normal)
        self.creditsLabel.text = NSLocalizedString("credits", comment: "")
        self.emailButton.setTitle(NSLocalizedString("email", comment: ""), for: .normal)
        let formatString = NSLocalizedString("build_version", comment: "")
        self.buildLabel.text = String(format: formatString, arguments: [Bundle.main.versionNumber])
    }

}
