//
//  FullSyncViewController.swift
//  llitgi
//
//  Created by Xavi Moll on 11/02/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit

private enum State {
    case loading
    case loaded
    case error
}

class FullSyncViewController: ViewController {
    
    //MARK: IBOutlets
    @IBOutlet var syncTitleLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var syncExplanationLabel: UILabel!
    @IBOutlet var syncDoneButton: UIButton!
    
    //MARK: Private properties
    private var state: State = .loading {
        didSet {
            switch state {
            case .loading:
                self.syncTitleLabel.text = NSLocalizedString("sync_title", comment: "")
                self.syncExplanationLabel.text = NSLocalizedString("sync_explanation", comment: "")
                UIView.animate(withDuration: 0.25) {
                    self.activityIndicator.isHidden = false
                    self.syncDoneButton.isHidden = true
                }
            case .loaded:
                self.syncTitleLabel.text = NSLocalizedString("sucess", comment: "")
                self.syncExplanationLabel.text = NSLocalizedString("sync_explanation_success", comment: "")
                self.syncDoneButton.setTitle(NSLocalizedString("lets_go", comment: ""), for: .normal)
                UIView.animate(withDuration: 0.25) {
                    self.activityIndicator.isHidden = true
                    self.syncDoneButton.isHidden = false
                }
            case .error:
                self.syncTitleLabel.text = NSLocalizedString("error_title", comment: "")
                self.syncExplanationLabel.text = NSLocalizedString("error_pocket", comment: "")
                self.syncDoneButton.setTitle(NSLocalizedString("retry", comment: ""), for: .normal)
                UIView.animate(withDuration: 0.25) {
                    self.activityIndicator.isHidden = true
                    self.syncDoneButton.isHidden = false
                }
            }
        }
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fullSync()
    }

    //MARK: IBActions
    @IBAction func finishButtonTapped(_ sender: UIButton) {
        switch self.state {
        case .loading:
            break
        case .loaded:
            self.dismiss(animated: true, completion: nil)
        case .error:
            self.fullSync()
        }
    }
    
    //MARK: Private methods
    private func fullSync() {
        self.state = .loading
        self.syncManager.sync(fullSync: true) { [weak self] (result: Result<[CoreDataItem]>) in
            guard let strongSelf = self else { return }
            switch result {
            case .isSuccess:
                strongSelf.state = .loaded
            case .isFailure(let error):
                strongSelf.state = .error
                Logger.log("Unable to perform a fullsync: \(error.localizedDescription)", event: .error)
            }
        }
    }
}
