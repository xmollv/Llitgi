//
//  SafariShowing.swift
//  llitgi
//
//  Created by Adrian Tineo on 24.07.18.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation
import SafariServices

protocol SafariShowing: class {
    func show(safariViewController: SFSafariViewController)
}
