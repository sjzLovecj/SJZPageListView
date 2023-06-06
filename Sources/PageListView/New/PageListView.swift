//
//  PageListView.swift
//  SJZPageListView
//
//  Created by S JZ on 2023/5/29.
//

import UIKit
import JXSegmentedView

public class PageListView: UIView {
    static let cellIdentifier = "cellIdentifier"
    
    public var configure: PageListConfigure = PageListConfigure()
    
    public var collectionView: UICollectionView { mainCollectionView }
    public var segmentView: JXSegmentedView { categroyView }
    
    fileprivate weak var delegate: PageListDelegate?
    fileprivate lazy var categroyView: JXSegmentedView = JXSegmentedView()
    fileprivate lazy var mainCollectionView: PageMainCollectionView = {
        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
        
        let mainCollectionView = PageMainCollectionView(frame: .zero, collectionViewLayout: layout)
        mainCollectionView.backgroundColor = .white
        mainCollectionView.showsVerticalScrollIndicator = false
        mainCollectionView.showsHorizontalScrollIndicator = false
        
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        mainCollectionView.gestureDelegate = self
        mainCollectionView.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: PageListView.cellIdentifier)
        
        
//        mainTableView.showsVerticalScrollIndicator = false
//        mainTableView.backgroundColor = UIColor.white
//        mainTableView.separatorStyle = .none
//        mainTableView.delegate = self
//        mainTableView.dataSource = self
//        mainTableView.gestureDelegate = self
//        mainTableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: PageListView.cellIdentifier)
        
        return mainCollectionView
    }()
    
    
    //MARK: - 屏蔽掉 init方法
    @available(*, unavailable, renamed: "init(delegate:)")
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable, renamed: "init(delegate:)")
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(delegate: PageListDelegate?) {
        super.init(frame: .zero)
        
        self.delegate = delegate
        addSubview(mainCollectionView)
        
//        segmentView.delegate = self
//        segmentView.
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        mainCollectionView.frame = self.bounds
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PageListView: UICollectionViewDelegateFlowLayout {
    // item Size
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard indexPath.section < configure.sectionDataArr.count, indexPath.item < configure.sectionDataArr[indexPath.section].cellDataArr.count else { return .zero }
        let itemData = configure.sectionDataArr[indexPath.section].cellDataArr[indexPath.item]
        return itemData.itemSize
    }
    
    // section edge
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard section < configure.sectionDataArr.count else { return .zero }
        let sectionData = configure.sectionDataArr[section]
        return sectionData.sectionEdgeInset
    }
    
    // minimumLineSpacingForSectionAt
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        guard section < configure.sectionDataArr.count else { return .zero }
        let sectionData = configure.sectionDataArr[section]
        return sectionData.lineSpacing
    }
    
    // minimumInteritemSpacingForSectionAt
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        guard section < configure.sectionDataArr.count else { return .zero }
        let sectionData = configure.sectionDataArr[section]
        return sectionData.interitemSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }
}

extension PageListView: UICollectionViewDelegate, UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        // 如果 segmentListViewArr 为nil，返回 configure.sectionDataArr.count
        guard configure.segmentListViewArr.isEmpty else { return configure.sectionDataArr.count }
        // 如果 segmentListViewArr 不为nil，返回 configure.sectionDataArr.count + 1，
        return configure.sectionDataArr.count + 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section < configure.sectionDataArr.count {
            return configure.sectionDataArr[section].cellDataArr.count
        }else {
            if configure.segmentListViewArr.count > 0 { return 1 }
        }
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section < configure.sectionDataArr.count {
            let sectionData = configure.sectionDataArr[indexPath.section]
            if indexPath.item < sectionData.cellDataArr.count {
                let cellData = sectionData.cellDataArr[indexPath.item]
                // 初始化Cell
                if let function = delegate?.pageCollectionView(_:cellData:cellForItemAt:),
                    let cell = function(collectionView, cellData, indexPath) {
                    return cell
                }
            }
        }else {
            // 初始化底部Cell
        }
        
        return UICollectionViewCell()
    }
    
    
    
    
    
//    public func numberOfSections(in tableView: UITableView) -> Int {
//        // 如果 segmentListViewArr 为nil，返回 configure.sectionDataArr.count
//        guard configure.segmentListViewArr.isEmpty else { return configure.sectionDataArr.count }
//        // 如果 segmentListViewArr 不为nil，返回 configure.sectionDataArr.count + 1，
//        return configure.sectionDataArr.count + 1
//    }
//
//    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section < configure.sectionDataArr.count {
//            return configure.sectionDataArr[section].cellDataArr.count
//        }else {
//            if configure.segmentListViewArr.count > 0 { return 1 }
//        }
//        return 0
//    }
//
//    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section < configure.sectionDataArr.count {
//            let sectionData = configure.sectionDataArr[indexPath.section]
//            if indexPath.row < sectionData.cellDataArr.count {
//                let cellData = sectionData.cellDataArr[indexPath.row]
//                // 初始化Cell
//                if let function = delegate?.pageTableView(_:cellData:cellForRowAt:),
//                    let cell = function(tableView, cellData, indexPath) {
//                    cell.selectionStyle = .none
//                    return cell
//                }
//            }
//        }else {
//            // 初始化底部Cell
//
//        }
//
//        return UITableViewCell(style: .default, reuseIdentifier: PageListView.cellIdentifier)
//    }
    
    
    
}


extension PageListView: PageMainTableViewGestureDelegate {
    
}


