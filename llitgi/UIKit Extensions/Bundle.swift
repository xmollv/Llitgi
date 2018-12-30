//
//  Bundle.swift
//  llitgi
//
//  Created by Xavi Moll on 22/02/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation

extension Bundle {
    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
}
