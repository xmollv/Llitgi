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
        default: self = .dark
        }
    }
    
    var tintColor: UIColor {
        switch self {
        case .light: return .black
        case .dark: return UIColor(displayP3Red: 194/255, green: 147/255, blue: 61/255, alpha: 1)
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .light: return .white
        case .dark: return UIColor(displayP3Red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
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
        case .light: return UIColor(displayP3Red: 230/255, green: 228/255, blue: 226/255, alpha: 1)
        case .dark: return UIColor(displayP3Red: 60/255, green: 60/255, blue: 60/255, alpha: 1)
        }
    }
    
    var pullToRefreshColor : UIColor {
        switch self {
        case .light: return .black
        case .dark: return .white
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
    
    var separatorColor: UIColor {
        switch self {
        case .light: return UIColor.black.withAlphaComponent(0.15)
        case .dark: return UIColor.white.withAlphaComponent(0.15)
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
    
    var sectionHeaderBackground: UIColor {
        switch self {
        case .light: return UIColor(displayP3Red: 45/255, green: 45/255, blue: 45/255, alpha: 1)
        case .dark: return UIColor(displayP3Red: 45/255, green: 45/255, blue: 45/255, alpha: 1)
        }
    }
}

