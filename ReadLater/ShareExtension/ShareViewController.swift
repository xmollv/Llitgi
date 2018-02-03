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
        
        let extensionItem = extensionContext?.inputItems.first as! NSExtensionItem
        let itemProvider = extensionItem.attachments?.first as! NSItemProvider
        let propertyList = String(kUTTypePropertyList)
        if itemProvider.hasItemConformingToTypeIdentifier(propertyList) {
            itemProvider.loadItem(forTypeIdentifier: propertyList, options: nil, completionHandler: { (item, error) -> Void in
                guard let dictionary = item as? NSDictionary else { return }
                OperationQueue.main.addOperation {
                    if let results = dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary,
                        let urlString = results["URL"] as? String,
                        let url = URL(string: urlString) {
                        print("URL retrieved: \(url)")
                        
                        self.APIManager.perform(endpoint: .add(url), then: { (result: Result<JSONArray>) in
                            switch result {
                            case .isSuccess:
                                break
                            case .isFailure(let error):
                                Logger.log("Unable to save the URL. \(error)", event: .error)
                            }
                            self.dismiss()
                        })
                        
                    }
                }
            })
        } else {
            print("error")
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
