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
    
    //MARK:- Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clearCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.clearCell()
    }
    
    private func clearCell() {
        self.favoriteView.isHidden = true
        self.titleLabel.text = nil
        self.urlLabel.text = nil
    }
    
    //MARK:- Public methods
    func configure(with item: Item) {
        if item.isFavorite {
            self.favoriteView.isHidden = false
        }
        self.titleLabel.text = item.title
        self.urlLabel.text = item.url.host
    }
    
}
