//
//  EmptyDetailViewController.swift
//  llitgi
//
//  Created by Xavi Moll on 07/08/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit

class EmptyDetailViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet private var messageLabel: UILabel!
    
    //MARK: Lifecycle
    init() {
        super.init(nibName: String(describing: EmptyDetailViewController.self), bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageLabel.text = L10n.General.emptyDetail
    }

}
