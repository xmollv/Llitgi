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
    @IBOutlet private var tagsCollectionView: UICollectionView!
    
    //MARK: Private properties
    private var item: Item?
    private var theme: Theme?
    
    //MARK:- Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tagsCollectionView.register(TagCell.self)
        if let flowLayout = self.tagsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 80, height: 25)
        }
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
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = self.favoriteView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        self.favoriteView.backgroundColor = color
    }
    
    private func clearCell() {
        self.item = nil
        self.theme = nil
        self.tagsCollectionView.delegate = nil
        self.tagsCollectionView.dataSource = nil
        self.favoriteView.isHidden = true
        self.titleLabel.text = nil
        self.urlLabel.text = nil
        self.tagsCollectionView.isHidden = true
    }
    
    //MARK:- Public methods
    func configure(with item: Item, theme: Theme) {
        self.item = item
        self.theme = theme
        self.tagsCollectionView.delegate = self
        self.tagsCollectionView.dataSource = self
        
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
        
        if item.tags.isEmpty {
            self.tagsCollectionView.isHidden = true
        } else {
            self.tagsCollectionView.isHidden = false
        }
    }
}

extension ListCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.item?.tags.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TagCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        if let tag = self.item?.tags[indexPath.row] {
            cell.configure(with: tag.name, theme: self.theme)
        } else {
            Logger.log("Unable to find the tag, this is a fatalError.", event: .error)
        }
        return cell
    }
}
