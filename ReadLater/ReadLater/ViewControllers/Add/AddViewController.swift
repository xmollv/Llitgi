//
//  AddViewController.swift
//  ReadLater
//
//  Created by Xavi Moll on 02/01/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit

class AddViewController: ViewController {

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkPasteboard()
    }
    
    //MARK: Private methods
    private func checkPasteboard() {
        guard let url = UIPasteboard.general.url else {
            Logger.log("The pasteboard doesn't contain any URL", event: .warning)
            return
        }
        
        self.dataProvider.performInMemoryWithoutResultType(endpoint: .add(url)) { [weak self] (result: EmptyResult) in
            guard let strongSelf = self else { return }
            switch result {
            case .isSuccess:
                NotificationCenter.default.post(name: .newUrlAdded, object: nil)
                strongSelf.dismiss(animated: true, completion: nil)
            case .isFailure(let error):
                Logger.log("Error: \(error)", event: .error)
            }
        }
    }
}
