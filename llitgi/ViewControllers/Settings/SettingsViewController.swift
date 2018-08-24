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
    @IBOutlet private var badgeCountLabel: UILabel!
    @IBOutlet private var badgeCountExplanationLabel: UILabel!
    @IBOutlet private var badgeCountSwitch: UISwitch!
    
    @IBOutlet private var safariOpenerLabel: UILabel!
    @IBOutlet private var safariOpenerExplanationLabel: UILabel!
    @IBOutlet private var safariOpenerSwitch: UISwitch!
    
    @IBOutlet private var safariReaderModeLabel: UILabel!
    @IBOutlet private var safariReaderModeExplanationLabel: UILabel!
    @IBOutlet private var safariReaderModeSwitch: UISwitch!
    
    @IBOutlet private var themeLabel: UILabel!
    @IBOutlet private var themeSegmentedControl: UISegmentedControl!
    
    @IBOutlet private var logoutButton: UIButton!
    
    @IBOutlet private var githubButton: UIButton!
    @IBOutlet private var twitterButton: UIButton!
    @IBOutlet private var emailButton: UIButton!
    @IBOutlet private var buildLabel: UILabel!
    
    //MARK: Private properties
    private let userManager: UserManager
    private let dataProvider: DataProvider
    private let themeManager: ThemeManager
    
    //MARK: Public properties
    var logoutBlock: (() -> Void)?
    var doneBlock: (() -> Void)?
    
    //MARK:- Lifecycle
    init(userManager: UserManager, dataProvider: DataProvider, themeManager: ThemeManager) {
        self.userManager = userManager
        self.dataProvider = dataProvider
        self.themeManager = themeManager
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
        self.establishSelectedTheme(theme: self.themeManager.theme)
        self.apply(theme: self.themeManager.theme, animated: false)
        self.themeManager.themeChanged = { [weak self] theme in
            self?.apply(theme: theme, animated: true)
        }
    }
    
    //MARK:- IBActions
    @IBAction private func done(_ sender: UIBarButtonItem) {
        self.doneBlock?()
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
        self.userManager.enableBadge(shouldEnable: sender.isOn) { (success) in
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
            self.userManager.openLinksWith = .safari
        case false:
            self.userManager.openLinksWith = .safariViewController
        }
    }
    
    private func establishReaderMode(readerEnabled: Bool) {
        self.safariReaderModeSwitch.setOn(readerEnabled, animated: false)
    }
    
    @IBAction func safariReaderModeChanged(_ sender: UISwitch) {
        self.userManager.openReaderMode = sender.isOn
    }
    
    private func establishSelectedTheme(theme: Theme) {
        switch theme {
        case .light:
            self.themeSegmentedControl.selectedSegmentIndex = 0
        case .dark:
            self.themeSegmentedControl.selectedSegmentIndex = 1
        }
    }
    
    @IBAction func themeSelectorChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.themeManager.theme = .light
        case 1:
            self.themeManager.theme = .dark
        default:
            assertionFailure("Unhandled segment")
        }
    }
    
    @IBAction private func logoutButtonTapped(_ sender: UIButton) {
        self.userManager.displayBadge(with: 0)
        self.logoutBlock?()
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
    private func apply(theme: Theme, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.25 : 0, animations: { [weak self] in
            self?.view.backgroundColor = theme.backgroundColor
            self?.themeLabel.textColor = theme.textTitleColor
        }, completion: nil)
    }
    
    private func setupLocalizedStrings() {
        self.title = L10n.Titles.settings
        self.badgeCountLabel.text = L10n.Settings.badgeCountTitle
        self.badgeCountExplanationLabel.text = L10n.Settings.badgeCountExplanation
        self.safariOpenerLabel.text = L10n.Settings.safariOpenerTitle
        self.safariOpenerExplanationLabel.text = L10n.Settings.safariOpenerDescription
        self.safariReaderModeLabel.text = L10n.Settings.safariReaderTitle
        self.safariReaderModeExplanationLabel.text = L10n.Settings.safariReaderDescription
        self.logoutButton.setTitle(L10n.General.logout, for: .normal)
        self.githubButton.setTitle(L10n.Settings.github, for: .normal)
        self.twitterButton.setTitle(L10n.Settings.twitter, for: .normal)
        self.emailButton.setTitle(L10n.Settings.email, for: .normal)
        let formatString = L10n.Settings.buildVersion
        self.buildLabel.text = String(format: formatString, arguments: [Bundle.main.versionNumber])
        self.themeLabel.text = L10n.Settings.themeTitle
        self.themeSegmentedControl.setTitle(L10n.Settings.lightTheme, forSegmentAt: 0)
        self.themeSegmentedControl.setTitle(L10n.Settings.darkTheme, forSegmentAt: 1)
    }

}
