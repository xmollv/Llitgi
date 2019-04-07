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

class FullSyncViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet private var syncTitleLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var syncExplanationLabel: UILabel!
    @IBOutlet private var syncDoneButton: UIButton!
    
    //MARK: Private properties
    private let dataProvider: DataProvider
    private var state: State = .loading {
        didSet {
            switch state {
            case .loading:
                self.syncTitleLabel.text = L10n.Sync.title
                self.syncExplanationLabel.text = L10n.Sync.explanation
                UIView.animate(withDuration: 0.25) {
                    self.activityIndicator.isHidden = false
                    self.syncDoneButton.isHidden = true
                }
            case .loaded:
                self.syncTitleLabel.text = L10n.Sync.successTitle
                self.syncExplanationLabel.text = L10n.Sync.successExplanation
                self.syncDoneButton.setTitle(L10n.Sync.successButton, for: .normal)
                UIView.animate(withDuration: 0.25) {
                    self.activityIndicator.isHidden = true
                    self.syncDoneButton.isHidden = false
                }
            case .error:
                self.syncTitleLabel.text = L10n.General.errorTitle
                self.syncExplanationLabel.text = L10n.General.pocketError
                self.syncDoneButton.setTitle(L10n.General.retry, for: .normal)
                UIView.animate(withDuration: 0.25) {
                    self.activityIndicator.isHidden = true
                    self.syncDoneButton.isHidden = false
                }
            }
        }
    }
    
    //MARK: Public properties
    var finishedSyncing: (() -> Void)?
    
    //MARK: Lifecycle
    init(dataProvider: DataProvider) {
        self.dataProvider = dataProvider
        super.init(nibName: String(describing: FullSyncViewController.self), bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
            self.finishedSyncing?()
        case .error:
            self.fullSync()
        }
    }
    
    //MARK: Private methods
    private func fullSync() {
        self.state = .loading
        self.dataProvider.syncLibrary(fullSync: true) { [weak self] (result: Result<[Item], Error>) in
            guard let strongSelf = self else { return }
            switch result {
            case .success:
                strongSelf.state = .loaded
            case .failure(let error):
                strongSelf.state = .error
                Logger.log(error.localizedDescription, event: .error)
            }
        }
    }
}
