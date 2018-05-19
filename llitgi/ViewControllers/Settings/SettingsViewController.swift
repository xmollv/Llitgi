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
    
    //MARK: Public properties
    var logoutBlock: (() -> ())? = nil
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.done(_:)))
        self.setupLocalizedStrings()
        self.badgeCount(isEnabled: self.userPreferences.userHasEnabledNotifications)
        self.safariOpenerValue(opener: self.userPreferences.openLinksWith)
        self.establishReaderMode(readerEnabled: self.userPreferences.openReaderMode)
    }
    
    //MARK:- IBActions
    @IBAction private func done(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
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
        self.logoutBlock?()
        self.dismiss(animated: true, completion: nil)
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
        self.title = L10n.Titles.settings
        self.badgeCountLabel.text = L10n.Settings.badgeCountTitle
        self.badgeCountExplanationLabel.text = L10n.Settings.badgeCountExplanation
        self.safariOpenerLabel.text = L10n.Settings.safariOpenerTitle
        self.safariOpenerExplanationLabel.text = L10n.Settings.safariOpenerDescription
        self.safariReaderModeLabel.text = L10n.Settings.safariReaderTitle
        self.safariReaderModeExplanationLabel.text = L10n.Settings.safariReaderDescription
        self.logoutButton.setTitle(L10n.General.logout, for: .normal)
        self.creditsLabel.text = L10n.Settings.credits
        self.emailButton.setTitle(L10n.Settings.email, for: .normal)
        let formatString = L10n.Settings.buildVersion
        self.buildLabel.text = String(format: formatString, arguments: [Bundle.main.versionNumber])
    }

}
