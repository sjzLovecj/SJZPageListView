//
//  ViewController.swift
//  SJZPageListView
//
//  Created by SJZ on 2021/9/29.
//

import UIKit

class ViewController: UIViewController {

    lazy var pageListView: PageListView = {
        let pageListView = PageListView(delegate: self)
        
        return pageListView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let itemData = PageListCellData()
        itemData.itemSize = CGSize(width: (view.frame.size.width - 30) / 2, height: 50)
        
        let sectionData = PageListSectionData()
        sectionData.cellDataArr = [itemData, itemData]
        sectionData.sectionEdgeInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        let itemData1 = PageListCellData()
        itemData1.itemSize = CGSize(width: view.frame.size.width - 20, height: 100)
        
        let sectionData1 = PageListSectionData()
        sectionData1.cellDataArr = [itemData1, itemData1]
        sectionData1.sectionEdgeInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let itemData2 = PageListCellData()
        itemData2.itemSize = CGSize(width: (view.frame.size.width - 20 - 30) / 4, height: 100)
        
        let sectionData2 = PageListSectionData()
        sectionData2.cellDataArr = [itemData2, itemData2, itemData2, itemData2, itemData2, itemData2, itemData2, itemData2]
        sectionData2.sectionEdgeInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        sectionData2.lineSpacing = 10
        sectionData2.interitemSpacing = 10
        
        let itemData3 = PageListCellData()
        itemData3.itemSize = CGSize(width: (view.frame.size.width - 30) / 2, height: 95)
        
        
        let itemData4 = PageListCellData()
        itemData4.itemSize = CGSize(width: (view.frame.size.width - 30) / 2, height: 200)
        
        let sectionData3 = PageListSectionData()
        sectionData3.cellDataArr = [itemData4, itemData3, itemData3, itemData3, itemData3, itemData3]
        sectionData3.sectionEdgeInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        sectionData3.lineSpacing = 10
        sectionData3.interitemSpacing = 10
        
        pageListView.configure.sectionDataArr = [sectionData, sectionData1, sectionData2, sectionData3]
        
        // 添加子视图
        view.addSubview(pageListView)
        
        
        pageListView.collectionView.reloadData()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        pageListView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
    }
}


extension ViewController: PageListDelegate {
    func pageCollectionView(_ collectionView: UICollectionView, cellData: PageListCellData, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PageListView.cellIdentifier, for: indexPath)
        cell.backgroundColor = UIColor(red: CGFloat(arc4random() % 255) / 255.0, green: CGFloat(arc4random() % 255) / 255.0, blue: CGFloat(arc4random() % 255) / 255.0, alpha: 1.0)
        return cell
    }
}

