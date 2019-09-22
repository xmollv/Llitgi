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
    @IBOutlet private var visualEffectView: UIVisualEffectView!
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
        self.visualEffectView.layer.cornerRadius = 10
        self.visualEffectView.layer.cornerCurve = .continuous
        self.visualEffectView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.visualEffectView.layer.masksToBounds = true
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
        
        guard let firstInputItem = (self.extensionContext?.inputItems.first as? NSExtensionItem) else {
            Logger.log("The inputItem is nil", event: .error)
            self.dismiss()
            return
        }
        
        guard let itemProvider = firstInputItem.attachments?.first(where: { $0.hasItemConformingToTypeIdentifier(kUTTypeURL as String) }) else {
            self.checkForURLsInPlainText(attachments: firstInputItem.attachments)
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
    
    private func dismiss() {
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss()
    }
    
    @IBAction func retryButtonTapped(_ sender: UIButton) {
        self.state = .loading
        self.performRequest()
    }
    
    private func checkForURLsInPlainText(attachments: [NSItemProvider]?) {
        guard let itemProvider = attachments?.first(where: { $0.hasItemConformingToTypeIdentifier(kUTTypeText as String) }) else {
            Logger.log("The item was nil", event: .error)
            self.dismiss()
            return
        }
        
        itemProvider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil) { [weak self] item, error in
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
            
            guard let sharedText = item as? String else {
                strongSelf.dismiss()
                return
            }
            
            guard let match = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue).matches(in: sharedText,
                                                                                                                  options: [],
                                                                                                                  range: NSRange(location: 0, length: sharedText.utf16.count)).first else {
                                                                                                                    strongSelf.dismiss()
                                                                                                                    return
            }
            
            guard let urlRange = Range(match.range, in: sharedText) else {
                strongSelf.dismiss()
                return
            }
            let textUrl = sharedText[urlRange]
            guard let url = URL(string: String(textUrl)) else {
                strongSelf.dismiss()
                return
            }
            
            strongSelf.url = url
            strongSelf.performRequest()
        }
    }
    
    private func performRequest() {
        guard let url = self.url else {
            Logger.log("The URL was nil", event: .error)
            self.dismiss()
            return
        }
        
        self.APIManager.perform(endpoint: .add(url)) { [weak self] (result: Result<JSONArray, Error>) in
            guard let strongSelf = self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
                strongSelf.dismiss()
            case .failure(let error):
                DispatchQueue.main.async {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
                strongSelf.state = .error
                Logger.log(error.localizedDescription, event: .error)
            }
        }
    }

}
