//
//  AddViewController.swift
//  ReadLater
//
//  Created by Xavi Moll on 02/01/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit

class AddViewController: ViewController {

    //MARK:- IBOutlets
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var pasteboardLabel: UILabel!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.checkPasteboard()
    }
    
    //MARK: Private methods
    private func checkPasteboard() {
        guard let url = UIPasteboard.general.url else {
            Logger.log("The pasteboard doesn't contain any URL", event: .warning)
            self.titleLabel.text = NSLocalizedString("Oops...", comment: "")
            self.pasteboardLabel.text = NSLocalizedString("Your pasteboard doesn't seem to contain any URL.", comment: "")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            return
        }
        
        self.titleLabel.text = NSLocalizedString("Saving URL...", comment: "")
        self.pasteboardLabel.text = url.absoluteString
        
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
