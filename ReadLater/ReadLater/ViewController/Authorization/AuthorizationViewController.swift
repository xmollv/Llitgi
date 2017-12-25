//
//  AuthorizationViewController.swift
//  ReadLater
//
//  Created by Xavi Moll on 24/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import UIKit

enum OAuthStep {
    case notStarted
    case requestToken
    case webOAuth
    case authorizeToken
    case finished
}

class AuthorizationViewController: ViewController {
    
    //MARK:- IBOutlets
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var actionButton: UIButton!
    
    //MARK:- Private properties
    private var state: OAuthStep = .notStarted

    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLocalizedStrings()
    }
    
    //MARK: IBActions
    @IBAction private func actionButtonTapped(_ sender: UIButton) {
        
    }
    
    //MARK: Private methods
    private func setupLocalizedStrings() {
        self.descriptionLabel.text = NSLocalizedString("Hey there! We need your permission to access your Pocket list. To do so, simply tap the button below.", comment: "")
        self.actionButton.setTitle(NSLocalizedString("Let's do it!", comment: ""), for: .normal)
    }

}
