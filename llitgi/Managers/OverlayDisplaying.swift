//
//  OverlayDisplaying.swift
//  llitgi
//
//  Created by Adrian Tineo on 04.08.18.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation

protocol OverlayDisplaying: class {
    func overlayDisplayMode(shouldBeSet: Bool)
    func isOverlayDisplayModeSet() -> Bool
}
