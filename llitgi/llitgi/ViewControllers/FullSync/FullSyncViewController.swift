//
//  FullSyncViewController.swift
//  llitgi
//
//  Created by Xavi Moll on 11/02/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit

class FullSyncViewController: ViewController {
    
    //MARK: IBOutlets
    @IBOutlet var syncTitleLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var syncExplanationLabel: UILabel!
    @IBOutlet var syncDoneButton: UIButton!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.syncTitleLabel.text = NSLocalizedString("sync_title", comment: "")
        self.syncExplanationLabel.text = NSLocalizedString("sync_explanation", comment: "")
        self.syncDoneButton.setTitle(NSLocalizedString("lets_go", comment: ""), for: .normal)
        self.syncDoneButton.isHidden = true
    }

    //MARK: IBActions
    @IBAction func finishButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: SyncManagerDelegate
extension FullSyncViewController: SyncManagerDelegate {
    func syncFinished() {
        self.syncTitleLabel.text = NSLocalizedString("sucess", comment: "")
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 2.5, animations: {
            self.activityIndicator.isHidden = true
            self.syncDoneButton.isHidden = false
        }, completion: nil)
    }
}
