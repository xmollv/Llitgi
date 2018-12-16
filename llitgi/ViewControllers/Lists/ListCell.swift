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
    @IBOutlet private var tagsView: TagsView!
    
    //MARK: Private properties
    private var item: Item?
    private var theme: Theme?
    
    //MARK: Public properties
    var selectedTag: ((Tag) -> Void)? = nil
    
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
        self.tagsView.tagsViews.forEach({ $0.backgroundColor = self.tagsView.tagsBackgroundColor })
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = self.favoriteView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        self.favoriteView.backgroundColor = color
        self.tagsView.tagsViews.forEach({ $0.backgroundColor = self.tagsView.tagsBackgroundColor })
    }
    
    private func clearCell() {
        self.item = nil
        self.theme = nil
        self.selectedTag = nil
        self.favoriteView.isHidden = true
        self.titleLabel.text = nil
        self.urlLabel.text = nil
        self.tagsView.clearTags()
        self.tagsView.isHidden = true
    }
    
    //MARK:- Public methods
    func configure(with item: Item, theme: Theme) {
        self.item = item
        self.theme = theme
        
        self.titleLabel.text = item.title
        self.urlLabel.text = item.url.host
        self.backgroundColor = theme.backgroundColor
        self.titleLabel.textColor = theme.textTitleColor
        self.urlLabel.textColor = theme.textSubtitleColor
        
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = theme.highlightBackgroundColor
        
        if item.isFavorite {
            self.favoriteView.isHidden = false
        }
        
        if !item.tags.isEmpty {
            self.tagsView.isHidden = false
            self.tagsView.tagsBackgroundColor = theme.separatorColor
            self.tagsView.tagsTextColor = theme.textSubtitleColor
            self.tagsView.selectedTag = { [weak self] tag in
                self?.selectedTag?(tag)
            }
            self.tagsView.add(tags: item.tags)
        }
    }
}
