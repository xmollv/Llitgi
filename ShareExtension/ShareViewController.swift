//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Xavi Moll on 03/02/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

enum ShareState {
    case loading
    case error
}

class ShareViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var retryButton: UIButton!
    
    //MARK: Private properties
    private let APIManager = PocketAPIManager()
    private var url: URL? = nil
    private var state: ShareState = .loading {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                switch strongSelf.state {
                case .loading:
                    strongSelf.titleLabel.text = L10n.ShareExtension.saving
                    strongSelf.activityIndicator.startAnimating()
                    strongSelf.activityIndicator.isHidden = false
                    strongSelf.retryButton.isHidden = true
                case .error:
                    strongSelf.titleLabel.text = L10n.General.pocketError
                    strongSelf.activityIndicator.stopAnimating()
                    strongSelf.activityIndicator.isHidden = true
                    strongSelf.retryButton.isHidden = false
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.closeButton.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.closeButton.isHidden = false
            strongSelf.closeButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, animations: {
                strongSelf.closeButton.transform = .identity
            }, completion: nil)
        }
        
        self.state = .loading
        self.retryButton.setTitle(L10n.General.retry, for: .normal)
        
        guard let itemProvider = (self.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments?.first as? NSItemProvider else {
            Logger.log("The itemProvider can't be found", event: .error)
            self.dismiss()
            return
        }
        
        guard itemProvider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) else {
            Logger.log("The itemProvider doesn't have an URL in it", event: .error)
            self.dismiss()
            return
        }
        
        itemProvider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { [weak self] (item, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                Logger.log(error.localizedDescription, event: .error)
                strongSelf.dismiss()
                return
            }
            
            guard let item = item else {
                Logger.log("The item was nil", event: .error)
                strongSelf.dismiss()
                return
            }
            
            guard let url = URL(string: String(describing: item)) else {
                Logger.log("Unable to create an URL from: \(String(describing: item))", event: .error)
                strongSelf.dismiss()
                return
            }
            
            strongSelf.url = url
            strongSelf.performRequest()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        self.view.alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.view.transform = .identity
            self.view.alpha = 1
        }
    }
    
    private func dismiss() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, animations: {
                self.view.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
                self.view.alpha = 0
            }) { (finished) in
                self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            }
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss()
    }
    
    @IBAction func retryButtonTapped(_ sender: UIButton) {
        self.state = .loading
        self.performRequest()
    }
    
    private func performRequest() {
        guard let url = self.url else {
            Logger.log("The URL was nil", event: .error)
            self.dismiss()
            return
        }
        
        self.APIManager.perform(endpoint: .add(url)) { [weak self] (result: Result<JSONArray>) in
            guard let strongSelf = self else { return }
            switch result {
            case .isSuccess:
                DispatchQueue.main.async {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
                strongSelf.dismiss()
            case .isFailure(let error):
                DispatchQueue.main.async {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
                strongSelf.state = .error
                Logger.log(error.localizedDescription, event: .error)
            }
        }
    }

}
