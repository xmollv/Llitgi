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
    
    @IBOutlet private var logoutButton: UIButton!
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.setupLocalizedStrings()
    }
    
    //MARK:- IBActions
    @IBAction private func badgeCountValueChanged(_ sender: UISwitch) {
        //TODO: Missing implementation
        // This should call a manager to trigger for enabling the notifications
        // The badge should be updated from the 'My List' view controller
        // or by creating new fetch request that only returns the count of elements on 'My List'
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
        self.logoutButton.setTitle(NSLocalizedString("Logout", comment: ""), for: .normal)
    }

}
