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
        case .dark: return UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
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
        case .light: return .darkGray
        case .dark: return .lightGray
        }
    }
    
    var highlightBackgroundColor: UIColor {
        switch self {
        case .light: return UIColor(red: 230/255, green: 228/255, blue: 226/255, alpha: 1)
        case .dark: return UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1)
        }
    }
    
    var keyboardAppearance: UIKeyboardAppearance {
        switch self {
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var indicatorStyle: UIScrollView.IndicatorStyle {
        switch self {
        case .light: return .black
        case .dark: return .white
        }
    }
    
    var statusBarStyle: UIStatusBarStyle {
        switch self {
        case .light: return .default
        case .dark: return .lightContent
        }
    }
    
    var barStyle: UIBarStyle {
        switch self {
        case .light: return .default
        case .dark: return .black
        }
    }
}

final class ThemeManager {
    
    typealias ThemeChanged = (_ theme: Theme) -> Void
    
    //MARK:- Private properties
    private var themeChangedBlocks: [ThemeChanged] = []
    
    //MARK: Public properties
    var theme: Theme = .light {
        didSet {
            UserDefaults.standard.setValue(theme.rawValue, forKey: "savedTheme")
            self.themeChangedBlocks.forEach{ $0(theme) }
        }
    }
    var themeChanged: ThemeChanged? {
        didSet {
            guard let block = self.themeChanged else { return }
            //TODO: The array is holding the blocks in a strong way, therefore they are never being deallocated
            //and can cause the same call more times than extened.
            self.themeChangedBlocks.append(block)
        }
    }
    
    init() {
        self.theme = Theme(withName: UserDefaults.standard.string(forKey: "savedTheme") ?? "")
    }
}
