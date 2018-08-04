//
//  LlitgiUserDefaults.swift
//  llitgi
//
//  Created by Xavi Moll on 03/02/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation

let kAccesToken = "accessToken"
let kEnabledNotifications = "enabledNotifications"
let kSafariOpener = "safariOpener"
let kReaderMode = "readerMode"
let kLastSync = "lastSync"
let kGroupUserDefaults = "group.com.xmollv.llitgi"
let kEnabledOverlayMode = "enabledOverlayMode"

final class LlitgiUserDefaults {
    private init() {}
    
    static let shared = UserDefaults(suiteName: "group.com.xmollv.llitgi")!

}
