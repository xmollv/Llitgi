//
//  TagsView.swift
//  llitgi
//
//  Created by Xavi Moll on 16/12/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit
import Foundation

final class TagsView: UIView {
    
    //MARK: Private properties
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        return stackView
    }()
    private var buttonTags: [UIButton: Tag] = [:]
    
    //MARK: Public properties
    var selectedTag: ((Tag) -> Void)? = nil
    var tagsBackgroundColor: UIColor = .black
    var tagsTextColor: UIColor = .white
    
    //MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = .clear
        
        self.addSubview(self.scrollView)
        self.scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        self.scrollView.addSubview(self.stackView)
        self.stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        self.stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        self.stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        self.stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        self.stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
    }
    
    //MARK: Public methods
    func add(tags: [Tag]) {
        tags.forEach { tag in
            let tagButton = UIButton()
            tagButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            tagButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .caption2)
            tagButton.layer.cornerRadius = 2
            tagButton.layer.masksToBounds = true
            tagButton.backgroundColor = self.tagsBackgroundColor
            tagButton.setTitleColor(self.tagsTextColor, for: .normal)
            tagButton.setTitle(tag.name, for: .normal)
            tagButton.addTarget(self, action: #selector(self.selected(tagButton:)), for: .touchUpInside)
            self.buttonTags[tagButton] = tag
            self.stackView.addArrangedSubview(tagButton)
        }
    }
    
    func clearTags() {
        self.buttonTags.removeAll()
        self.stackView.arrangedSubviews.forEach {
            self.stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
    
    //MARK: Private methods
    @objc
    private func selected(tagButton: UIButton) {
        guard let tag = self.buttonTags[tagButton] else {
            assertionFailure("Unable to find the tag")
            return
        }
        self.selectedTag?(tag)
    }
}
