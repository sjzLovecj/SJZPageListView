//
//  PageListDelegate.swift
//  SJZPageListView
//
//  Created by S JZ on 2023/5/29.
//

import UIKit

@objc public protocol PageListDelegate {
    
    
    // MARK: - TableView 代理
//    @objc optional func pageNumberOfSections(in tableView: UITableView)
    
    @objc optional func pageCollectionView(_ collectionView: UICollectionView, cellData: PageListCellData, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell?
}
