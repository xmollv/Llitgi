//
//  SectionHeaderView.swift
//  llitgi
//
//  Created by Xavi Moll on 23/12/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit
import Foundation

final class SectionHeaderView: UIView {
    
    var text: String? {
        didSet {
            self.label.text = text
        }
    }
    
    private var label = UILabel()
    
    init(theme: Theme) {
        super.init(frame: .zero)
        self.backgroundColor = theme.sectionHeaderBackground
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = theme.textTitleColor
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        self.addSubview(label)
        
        label.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        label.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 20).isActive = true
        label.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        let bottomConstraint = label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5)
        bottomConstraint.priority = UILayoutPriority.init(999)
        bottomConstraint.isActive = true
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
