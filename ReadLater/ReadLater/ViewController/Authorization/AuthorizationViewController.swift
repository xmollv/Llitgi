//
//  AuthorizationViewController.swift
//  ReadLater
//
//  Created by Xavi Moll on 24/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import UIKit

class AuthorizationViewController: ViewController {
    
    //MARK:- IBOutlets
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var actionButton: UIButton!

    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.verifyCodeAndGetToken), name: .OAuthFinished, object: nil)
        self.setupLocalizedStrings()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: IBActions
    @IBAction private func actionButtonTapped(_ sender: UIButton) {
        sender.isEnabled = false
        // Step 1. Grab the token to initiate the OAuth steps
        self.dataProvider.perform(endpoint: .requestToken) { [weak self] (result: Result<[RequestTokenResponse]>) in
            sender.isEnabled = true
            guard let strongSelf = self else { return }
            switch result {
            case .isSuccess(let tokenResponse):
                guard let code = tokenResponse.first?.code else {
                    Logger.log("The tokenResponse was an empty array.", event: .error)
                    return
                }
                strongSelf.dataProvider.updatePocket(code: code)
                
                // Step 2. Open Safari to perform the Oauth
                if UIApplication.shared.canOpenURL(URL(string: "pocket-oauth-v1://")!) {
                    guard let url = strongSelf.dataProvider.urlForPocketOAuthApp else { return }
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    guard let url = strongSelf.dataProvider.urlForPocketOAuthWebsite else { return }
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                
            case .isFailure(let error):
                dump(error)
            }
        }
    }
    
    //MARK: Private methods
    private func setupLocalizedStrings() {
        self.descriptionLabel.text = NSLocalizedString("Hey there! We need your permission to access your Pocket list. To do so, simply tap the button below.", comment: "")
        self.actionButton.setTitle(NSLocalizedString("Let's do it!", comment: ""), for: .normal)
    }
    
    //Step 3. Verify the code against the API once the user has finished the OAuth flow
    @objc private func verifyCodeAndGetToken() {
        self.dataProvider.perform(endpoint: .authorize) { [weak self] (result: Result<[AuthorizeTokenResponse]>) in
            guard let strongSelf = self else { return }
            switch result {
            case .isSuccess(let tokenResponse):
                guard let token = tokenResponse.first?.accessToken else {
                    Logger.log("The tokenResponse was an empty array.", event: .error)
                    return
                }
                strongSelf.dataProvider.updatePocket(token: token)
                
                let listViewController: ListViewController = strongSelf.factory.instantiate()
                strongSelf.tabBarController?.setViewControllers([listViewController], animated: false)
                strongSelf.tabBarController?.tabBar.isHidden = false
            case .isFailure(let error):
                dump(error)
            }
        }
    }

}
