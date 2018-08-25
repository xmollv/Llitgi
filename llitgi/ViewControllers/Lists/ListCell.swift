//
//  ListCell.swift
//  llitgi
//
//  Created by Xavi Moll on 25/12/2017.
//  Copyright © 2017 xmollv. All rights reserved.
//

import UIKit

class ListCell: UITableViewCell, NibLoadableView {

    //MARK:- IBOutlets
    @IBOutlet private var favoriteView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var urlLabel: UILabel!
    
    //MARK: Private properties
    private var theme: Theme?
    
    //MARK:- Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clearCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.clearCell()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = self.favoriteView.backgroundColor
        super.setSelected(selected, animated: animated)
        self.favoriteView.backgroundColor = color
    }
    
    private func clearCell() {
        self.theme = nil
        self.favoriteView.isHidden = true
        self.titleLabel.text = nil
        self.urlLabel.text = nil
    }
    
    //MARK:- Public methods
    func configure(with item: Item, theme: Theme) {
        self.theme = theme
        if item.isFavorite {
            self.favoriteView.isHidden = false
        }
        self.titleLabel.text = item.title
        self.urlLabel.text = item.url.host
        self.backgroundColor = theme.backgroundColor
        self.titleLabel.textColor = theme.textTitleColor
        self.urlLabel.textColor = theme.textSubtitleColor
        
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = theme.highlightBackgroundColor
    }
    
}
