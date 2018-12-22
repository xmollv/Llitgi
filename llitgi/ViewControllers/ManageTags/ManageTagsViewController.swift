//
//  ManageTagsViewController.swift
//  llitgi
//
//  Created by Xavi Moll on 22/12/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit

class ManageTagsViewController: UIViewController {
    
    enum Section: Int {
        case currentTags = 0
        case availableTags = 1
        
        init(section: Int) {
            switch section {
            case 0: self = .currentTags
            case 1: self = .availableTags
            default: fatalError("You've messed up.")
            }
        }
        
        var title: String {
            switch self {
            case .currentTags: return L10n.Tags.current
            case .availableTags: return L10n.Tags.available
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
