//
//  TagCell.swift
//  llitgi
//
//  Created by Xavi Moll on 26/10/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit

class TagCell: UICollectionViewCell, NibLoadableView {

    //MARK: IBOutlets
    @IBOutlet private(set) var label: UILabel!
    
    //MARK: Private properties
    var theme: Theme?
    
    //MARK: Public properties
    override var isSelected: Bool {
        didSet {
            self.backgroundColor = self.theme?.separatorColor
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            self.backgroundColor = self.theme?.separatorColor
        }
    }
    
    //MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clearCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.clearCell()
    }
    
    private func clearCell() {
        self.theme = nil
        self.label.text = nil
    }
    
    //MARK:- Public methods
    func configure(with tagName: String, theme: Theme?) {
        self.theme = theme
        self.backgroundColor = theme?.separatorColor
        self.label.textColor = theme?.textSubtitleColor
        self.label.text = tagName
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        super.preferredLayoutAttributesFitting(layoutAttributes)

        let labelWidth = systemLayoutSizeFitting(self.label.frame.size).width

        let targetSize = CGSize(width: labelWidth, height: 25)

        let autoLayoutSize = contentView.systemLayoutSizeFitting(targetSize,
                                                                 withHorizontalFittingPriority: UILayoutPriority.defaultLow,
                                                                 verticalFittingPriority: UILayoutPriority.required)

        layoutAttributes.frame = CGRect(origin: layoutAttributes.frame.origin, size: autoLayoutSize)
        return layoutAttributes
    }
    
}
