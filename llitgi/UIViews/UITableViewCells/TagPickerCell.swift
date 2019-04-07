//
//  TagPickerCell.swift
//  llitgi
//
//  Created by Xavi Moll on 22/12/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit

class TagPickerCell: UITableViewCell {

    @IBOutlet private var tagLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clearCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.clearCell()
    }
    
    private func clearCell() {
        self.tagLabel.text = nil
    }
    
    func configure(with tag: Tag, theme: Theme) {
        self.tagLabel.text = tag.name
        self.backgroundColor = theme.backgroundColor
        self.tagLabel.textColor = theme.textSubtitleColor
    }
    
}
