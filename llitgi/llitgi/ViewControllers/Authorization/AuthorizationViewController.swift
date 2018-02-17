//
//  AuthorizationViewController.swift
//  llitgi
//
//  Created by Xavi Moll on 24/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import UIKit

class AuthorizationViewController: ViewController {
    
    //MARK:- IBOutlets
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var actionButton: UIButton!
    @IBOutlet private var errorLabel: UILabel!
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.verifyCodeAndGetToken), name: .OAuthFinished, object: nil)
        self.actionButton.alpha = 0
        self.setupLocalizedStrings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.25, delay: 1.5, options: [], animations: {
            self.actionButton.alpha = 1
        }, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: IBActions
    @IBAction private func actionButtonTapped(_ sender: UIButton) {
        sender.isEnabled = false
        self.errorLabel.isHidden = true
        // Step 1. Grab the token to initiate the OAuth steps
        self.dataProvider.performInMemory(endpoint: .requestToken) { [weak self] (result: Result<[RequestTokenResponse]>) in
            sender.isEnabled = true
            guard let strongSelf = self else { return }
            switch result {
            case .isSuccess(let tokenResponse):
                guard let code = tokenResponse.first?.code else {
                    strongSelf.showErrorMessage()
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
                strongSelf.showErrorMessage()
                Logger.log("Error: \(error)", event: .error)
            }
        }
    }
    
    //MARK: Private methods
    private func setupLocalizedStrings() {
        self.descriptionLabel.text = NSLocalizedString("onboarding", comment: "")
        self.actionButton.setTitle(NSLocalizedString("lets_do_it", comment: ""), for: .normal)
    }
    
    //Step 3. Verify the code against the API once the user has finished the OAuth flow
    @objc private func verifyCodeAndGetToken() {
        self.dataProvider.performInMemory(endpoint: .authorize) { [weak self] (result: Result<[AuthorizeTokenResponse]>) in
            guard let strongSelf = self else { return }
            switch result {
            case .isSuccess(let tokenResponse):
                guard let token = tokenResponse.first?.accessToken else {
                    strongSelf.showErrorMessage()
                    Logger.log("The tokenResponse was an empty array.", event: .error)
                    return
                }
                strongSelf.dataProvider.updatePocket(token: token)
                guard let tabBarController = strongSelf.tabBarController as? TabBarController else { return }
                tabBarController.setupMainFlow()
            case .isFailure(let error):
                if let notAuthError = error as? PocketAPIError {
                    switch notAuthError {
                    case .not200Status(let statusCode):
                        if statusCode == 403 {
                            strongSelf.errorLabel.isHidden = false
                            strongSelf.errorLabel.text = NSLocalizedString("auth_error", comment: "")
                        }
                    default:
                        strongSelf.showErrorMessage()
                    }
                } else {
                    strongSelf.showErrorMessage()
                }
                Logger.log("Error: \(error)", event: .error)
            }
        }
    }
    
    private func showErrorMessage() {
        self.errorLabel.isHidden = false
        self.errorLabel.text = NSLocalizedString("error_pocket", comment: "")
    }

}
