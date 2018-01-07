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
    
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.setupLocalizedStrings()
    }
    
    //MARK:- IBActions
    @IBAction func badgeCountValueChanged(_ sender: UISwitch) {

    }
    
    //MARK:- Private methods
    private func setupLocalizedStrings() {
        self.titleLabel.text = NSLocalizedString("Settings", comment: "")
        self.badgeCountLabel.text = NSLocalizedString("Show app badge count", comment: "")
        self.badgeCountExplanationLabel.text = NSLocalizedString("This will display a badge count on the app icon on your homescreen with the number of elements on your list.", comment: "")
    }

}
