//
//  EmptyDetailViewController.swift
//  llitgi
//
//  Created by Adrian Tineo on 04.08.18.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation
import UIKit

class EmptyDetailViewController: UIViewController {
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.text = L10n.EmptyDetail.descriptionTitle
    }
}
