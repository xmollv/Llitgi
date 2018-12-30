//
//  UIColor.swift
//  llitgi
//
//  Created by Xavi Moll on 16/12/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit
import Foundation

// https://gist.github.com/soffes/68d355e828cb502f75c3b8f989962958
extension UIColor {
    var desaturated: UIColor {
        var hue: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        getHue(&hue, saturation: nil, brightness: &brightness, alpha: &alpha)
        
        return type(of: self).init(hue: hue, saturation: 0, brightness: brightness, alpha: alpha)
    }
}
