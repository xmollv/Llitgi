//
//  FullSyncViewController.swift
//  llitgi
//
//  Created by Xavi Moll on 11/02/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit

class FullSyncViewController: ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func dimissButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension FullSyncViewController: SyncManagerDelegate {
    func syncFinished() {
        self.dismiss(animated: true, completion: nil)
    }
}
