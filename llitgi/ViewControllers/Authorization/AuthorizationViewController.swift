//
//  AuthorizationViewController.swift
//  llitgi
//
//  Created by Xavi Moll on 24/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import UIKit
import SafariServices

class AuthorizationViewController: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var offlineTitleLabel: UILabel!
    @IBOutlet private var offlineDescriptionLabel: UILabel!
    @IBOutlet private var syncTitleLabel: UILabel!
    @IBOutlet private var syncDescriptionLabel: UILabel!
    @IBOutlet private var minimalistTitleLabel: UILabel!
    @IBOutlet private var minimalistDescriptionLabel: UILabel!
    @IBOutlet private var actionButton: UIButton!
    
    //MARK: Private properties
    private let dataProvider: DataProvider
    
    //MARK: Public properties
    var loginFinished: (() -> Void)?
    var safariToPresent: ((SFSafariViewController) -> Void)?
    
    //MARK:- Lifecycle
    init(dataProvider: DataProvider) {
        self.dataProvider = dataProvider
        super.init(nibName: String(describing: AuthorizationViewController.self), bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        self.dataProvider.performInMemory(endpoint: .requestToken) { [weak self] (result: Result<[RequestTokenResponse]>) in
            sender.isEnabled = true
            guard let strongSelf = self else { return }
            switch result {
            case .isSuccess(let tokenResponse):
                guard let code = tokenResponse.first?.code else {
                    strongSelf.presentErrorAlert()
                    Logger.log("The tokenResponse was an empty array.", event: .error)
                    return
                }
                strongSelf.dataProvider.updatePocket(code: code)
                
                // Step 2. Open Safari to perform the Oauth
                if UIApplication.shared.canOpenURL(URL(string: "pocket-oauth-v1://")!) {
                    guard let url = strongSelf.dataProvider.pocketOAuthUrls.app else { return }
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    guard let url = strongSelf.dataProvider.pocketOAuthUrls.web else { return }
                    let sfs = SFSafariViewController(url: url)
                    sfs.modalPresentationStyle = .formSheet
                    sfs.preferredControlTintColor = .black
                    sfs.preferredBarTintColor = .white
                    strongSelf.safariToPresent?(sfs)
                }
                
            case .isFailure(let error):
                strongSelf.presentErrorAlert()
                Logger.log(error.localizedDescription, event: .error)
            }
        }
    }
    
    //MARK: Private methods
    private func setupLocalizedStrings() {
        self.titleLabel.text = L10n.Onboarding.title
        self.offlineTitleLabel.text = L10n.Onboarding.offlineTitle
        self.offlineDescriptionLabel.text = L10n.Onboarding.offlineDescription
        self.syncTitleLabel.text = L10n.Onboarding.syncTitle
        self.syncDescriptionLabel.text = L10n.Onboarding.syncDescription
        self.minimalistTitleLabel.text = L10n.Onboarding.minimalistTitle
        self.minimalistDescriptionLabel.text = L10n.Onboarding.minimalistDescription
        self.actionButton.setTitle(L10n.Onboarding.button, for: .normal)
    }
    
    //Step 3. Verify the code against the API once the user has finished the OAuth flow
    @objc private func verifyCodeAndGetToken() {
        self.dismiss(animated: false, completion: nil)
        self.dataProvider.performInMemory(endpoint: .authorize) { [weak self] (result: Result<[AuthorizeTokenResponse]>) in
            guard let strongSelf = self else { return }
            switch result {
            case .isSuccess(let tokenResponse):
                guard let token = tokenResponse.first?.accessToken else {
                    strongSelf.presentErrorAlert()
                    Logger.log("The tokenResponse was an empty array.", event: .error)
                    return
                }
                strongSelf.dataProvider.updatePocket(token: token)
                strongSelf.loginFinished?()
            case .isFailure(let error):
                strongSelf.presentErrorAlert()
                Logger.log(error.localizedDescription, event: .error)
            }
        }
    }

}
