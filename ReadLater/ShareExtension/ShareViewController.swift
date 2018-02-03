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

class ShareViewController: UIViewController {
    
    let APIManager = PocketAPIManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let itemProvider = (self.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments?.first as? NSItemProvider else {
            Logger.log("The itemProvider can't be found", event: .error)
            return
        }
        
        guard itemProvider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) else {
            Logger.log("The itemProvider doesn't have an URL in it", event: .error)
            return
        }
        
        itemProvider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { [weak self] (item, error) in
            guard let strongSelf = self else { return }
            guard error == nil else {
                Logger.log("An error ocurred when loading the item: \(error.localizedDescription)", event: .error)
                return
            }
            
            guard let item = item else {
                Logger.log("The item was nil", event: .error)
                return
            }
            
            guard let url = URL(string: String(describing: item)) else {
                Logger.log("Unable to create an URL from: \(String(describing: item))", event: .error)
                return
            }
            
            strongSelf.APIManager.perform(endpoint: .add(url)) { (result: Result<JSONArray>) in
                switch result {
                case .isSuccess:
                    Logger.log("Sucess saving the URL")
                case .isFailure(let error):
                    Logger.log("Unable to save the URL. \(error)", event: .error)
                }
                strongSelf.dismiss()
            }
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

}
