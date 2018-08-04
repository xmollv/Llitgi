//
//  SettingsViewController.swift
//  llitgi
//
//  Created by Xavi Moll on 07/01/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    //MARK:- IBOutlets
    
    // Badge count
    @IBOutlet private var badgeCountLabel: UILabel!
    @IBOutlet private var badgeCountExplanationLabel: UILabel!
    @IBOutlet private var badgeCountSwitch: UISwitch!
    
    // Safari opener
    @IBOutlet private var safariOpenerLabel: UILabel!
    @IBOutlet private var safariOpenerExplanationLabel: UILabel!
    @IBOutlet private var safariOpenerSwitch: UISwitch!
    
    // Safari reader
    @IBOutlet private var safariReaderModeLabel: UILabel!
    @IBOutlet private var safariReaderModeExplanationLabel: UILabel!
    @IBOutlet private var safariReaderModeSwitch: UISwitch!
    
    // Overlay mode
    @IBOutlet weak var overlayModeStackView: UIStackView!
    @IBOutlet weak var overlayModeLabel: UILabel!
    @IBOutlet weak var overlayModeExplanationLabel: UILabel!
    @IBOutlet weak var overlayModeSwitch: UISwitch!
    
    // Other buttons
    @IBOutlet private var logoutButton: UIButton!
    @IBOutlet private var githubButton: UIButton!
    @IBOutlet private var twitterButton: UIButton!
    @IBOutlet private var emailButton: UIButton!
    @IBOutlet private var buildLabel: UILabel!
    
    //MARK: Private properties
    private let userManager: UserManager
    
    private weak var overlayDisplaying: OverlayDisplaying?
    
    //MARK: Public properties
    var logoutBlock: (() -> ())? = nil
    
    //MARK:- Lifecycle
    init(userManager: UserManager, overlayDisplaying: OverlayDisplaying) {
        self.userManager = userManager
        self.overlayDisplaying = overlayDisplaying
        super.init(nibName: String(describing: SettingsViewController.self), bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.done(_:)))
        self.setupLocalizedStrings()
        self.badgeCount(isEnabled: self.userManager.userHasEnabledNotifications)
        self.safariOpenerValue(opener: self.userManager.openLinksWith)
        self.establishReaderMode(readerEnabled: self.userManager.openReaderMode)
        
        if UIDevice.current.userInterfaceIdiom != .pad {
            overlayModeStackView.isHidden = true
        } else {
            self.overlayMode(isEnabled: self.userManager.userHasEnabledOverlayMode)
        }
    }
    
    //MARK:- IBActions
    @IBAction private func done(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            self.overlayDisplaying?.overlayDisplayMode(isEnabled: self.userManager.userHasEnabledOverlayMode)
        }
    }
    
    // Badge count
    private func badgeCount(isEnabled: Bool) {
        switch isEnabled {
        case true:
            self.badgeCountSwitch.setOn(true, animated: false)
        case false:
            self.badgeCountSwitch.setOn(false, animated: false)
        }
    }
    
    @IBAction private func badgeCountValueChanged(_ sender: UISwitch) {
        self.userManager.enableBadge(shouldEnable: sender.isOn) { (success) in
            if !success {
                sender.setOn(false, animated: true)
            }
        }
    }
    
    // Safari opener
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
            self.userManager.openLinksWith = .safari
        case false:
            self.userManager.openLinksWith = .safariViewController
        }
    }
    
    // Reader mode
    private func establishReaderMode(readerEnabled: Bool) {
        self.safariReaderModeSwitch.setOn(readerEnabled, animated: false)
    }
    
    @IBAction func safariReaderModeChanged(_ sender: UISwitch) {
        self.userManager.openReaderMode = sender.isOn
    }
    
    // Overlay mode
    private func overlayMode(isEnabled: Bool) {
        self.overlayModeSwitch.setOn(isEnabled, animated: false)
    }

    @IBAction func overlayModeChanged(_ sender: UISwitch) {
        self.userManager.userHasEnabledOverlayMode = sender.isOn
    }
    
    // Other buttons
    @IBAction private func logoutButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.logoutBlock?()
        }
    }
    
    @IBAction func githubButtonTapped(_ sender: UIButton) {
        guard let url = URL(string: "https://github.com/xmollv/llitgi") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func twitterButtonTapped(_ sender: UIButton) {
        guard let url = URL(string: "https://twitter.com/xmollv") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func emailButtonTapped(_ sender: UIButton) {
        guard let url = URL(string: "mailto:xmollv@gmail.com?subject=[Llitgi]") else { return }
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
        self.overlayModeLabel.text = L10n.Settings.overlayModeTitle
        self.overlayModeExplanationLabel.text = L10n.Settings.overlayModeDescription
        self.logoutButton.setTitle(L10n.General.logout, for: .normal)
        self.githubButton.setTitle(L10n.Settings.github, for: .normal)
        self.twitterButton.setTitle(L10n.Settings.twitter, for: .normal)
        self.emailButton.setTitle(L10n.Settings.email, for: .normal)
        let formatString = L10n.Settings.buildVersion
        self.buildLabel.text = String(format: formatString, arguments: [Bundle.main.versionNumber])
    }

}
