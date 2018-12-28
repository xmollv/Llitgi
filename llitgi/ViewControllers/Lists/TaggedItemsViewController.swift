//
//  TaggedItemsViewController.swift
//  llitgi
//
//  Created by Xavi Moll on 28/12/2018.
//  Copyright © 2018 xmollv. All rights reserved.
//

import UIKit
import Foundation

final class TaggedItemsViewController: BaseListViewController {
    
    //MARK:- Private properties
    private let tag: Tag
    
    //MARK:- Lifecycle
    init(notifier: CoreDataNotifier<CoreDataItem>, dataProvider: DataProvider, userManager: UserManager, themeManager: ThemeManager, tag: Tag) {
        self.tag = tag
        super.init(notifier: notifier, dataProvider: dataProvider, userManager: userManager, themeManager: themeManager)
        self.title = tag.name
    }
    
}

//MARK:- UITableViewDelegate
extension TaggedItemsViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard self.notifier.numberOfSections() > 1 else { return 0.0 }
        return (self.notifier.numberOfElements(inSection: section) > 0) ? UITableView.automaticDimension : 0.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = SectionHeaderView(theme: self.themeManager.theme)
        switch section {
        case 0:
            sectionHeaderView.text = L10n.Titles.myList
            return sectionHeaderView
        case 1:
            sectionHeaderView.text = L10n.Titles.archive
            return sectionHeaderView
        default:
            assertionFailure("Unhandled case")
            return nil
        }
    }
}
