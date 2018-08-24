//
//  Theme.swift
//  llitgi
//
//  Created by Xavi Moll on 24/08/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import Foundation
import UIKit

enum Theme: String {
    case light
    case dark
    
    init(withName name: String) {
        switch name {
        case "light": self = .light
        case "dark": self = .dark
        default: self = .light
        }
    }
    
    var tintColor: UIColor {
        switch self {
        case .light: return .black
        case .dark: return .white
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .light: return .white
        case .dark: return .black
        }
    }
    
    var textTitleColor: UIColor {
        switch self {
        case .light: return .black
        case .dark: return .white
        }
    }
    
    var textSubtitleColor: UIColor {
        switch self {
        case .light: return UIColor.black.withAlphaComponent(0.75)
        case .dark: return UIColor.white.withAlphaComponent(0.75)
        }
    }
}

final class ThemeManager {
    
    //MARK:- Private properties
    private var themeChangedBlocks: [(_ theme: Theme) -> Void] = []
    
    //MARK: Public properties
    var theme: Theme = .light {
        didSet {
            UserDefaults.standard.setValue(theme.rawValue, forKey: "savedTheme")
            self.themeChangedBlocks.forEach{ $0(theme) }
            //self.themeChanged?(theme)
        }
    }
    var themeChanged: ((_ theme: Theme) -> Void)? {
        didSet {
            guard let block = self.themeChanged else { return }
            self.themeChangedBlocks.append(block)
        }
    }
    
    init() {
        self.theme = Theme(withName: UserDefaults.standard.string(forKey: "savedTheme") ?? "")
    }
}
