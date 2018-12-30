//
//  UIViewController.swift
//  llitgi
//
//  Created by Xavi Moll on 23/05/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentErrorAlert(with title: String = L10n.General.errorTitle, and message: String = L10n.General.errorDescription) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: L10n.General.dismiss, style: .default, handler: nil)
        alertController.addAction(dismissAction)
        alertController.view.tintColor = .black
        self.present(alertController, animated: true, completion: nil)
    }
}
