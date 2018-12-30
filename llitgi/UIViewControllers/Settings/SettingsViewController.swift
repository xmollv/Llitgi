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
    @IBOutlet private var scrollView: UIScrollView!
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
    
    //MARK: Private properties
    private let userManager: UserManager
    private let dataProvider: DataProvider
    private let theme: Theme
    
    //MARK: Public properties
    var logoutBlock: (() -> Void)?
    var doneBlock: (() -> Void)?
    
    //MARK:- Lifecycle
    init(userManager: UserManager, dataProvider: DataProvider, theme: Theme) {
        self.userManager = userManager
        self.dataProvider = dataProvider
        self.theme = theme
        super.init(nibName: String(describing: SettingsViewController.self), bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.theme.statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.done(_:)))
        self.setupLocalizedStrings()
        self.establishBadgeCount(isEnabled: self.userManager.userHasEnabledNotifications)
        self.establishSafariOpenerValue(opener: self.userManager.openLinksWith)
        self.establishReaderMode(readerEnabled: self.userManager.openReaderMode)
        self.apply(self.theme)
    }
    
    //MARK:- IBActions
    @IBAction private func done(_ sender: UIBarButtonItem) {
        self.doneBlock?()
    }
    
    private func establishBadgeCount(isEnabled: Bool) {
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
            NotificationCenter.default.post(name: .badgeChanged, object: nil)
        }
    }
    
    private func establishSafariOpenerValue(opener: SafariOpener) {
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
    
    @IBAction private func logoutButtonTapped(_ sender: UIButton) {
        self.logoutBlock?()
    }
    
    //MARK:- Private methods
    private func apply(_ theme: Theme) {
        self.view.backgroundColor = theme.backgroundColor
        self.navigationController?.navigationBar.barStyle = theme.barStyle
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.textTitleColor]
        self.scrollView.indicatorStyle = theme.indicatorStyle
        self.badgeCountLabel.textColor = theme.textTitleColor
        self.badgeCountExplanationLabel.textColor = theme.textSubtitleColor
        self.safariOpenerLabel.textColor = theme.textTitleColor
        self.safariOpenerExplanationLabel.textColor = theme.textSubtitleColor
        self.safariReaderModeLabel.textColor = theme.textTitleColor
        self.safariReaderModeExplanationLabel.textColor = theme.textSubtitleColor
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
    }

}
