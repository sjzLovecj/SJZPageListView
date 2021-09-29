//
//  SJZPageListContainerView.swift
//  SJZPageListView
//
//  Created by SJZ on 2021/8/23.
//

import UIKit

protocol SJZPageListContainerViewDelegate: AnyObject {
    func numberOfRows(_ listcontainerView: SJZPageListContainerView) -> NSInteger
    func pageList(_ containerView: SJZPageListContainerView, listViewInRow row: NSInteger) -> UIView
    func pageList(_ containerView: SJZPageListContainerView, willDisplayCellAtRow row: NSInteger)
    func pageList(_ containerView: SJZPageListContainerView, didEndDisplayingCellAtRow row: NSInteger)
}

class SJZPageListContainerView: UIView {

    var defaultSelectedIndex: Int = 0
    var isFirstLayoutSubviews: Bool = false
    var selectedIndexPath: IndexPath?
    
    weak var mainTableView: SJZPageMainTableView?
    
    fileprivate weak var delegate: SJZPageListContainerViewDelegate?
    
    lazy var collectionView: SJZPageListCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collectionView = SJZPageListCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.scrollsToTop = false
        collectionView.bounces = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "cell")
        
        if #available(iOS 10.0, *) {
            collectionView.isPrefetchingEnabled = false
        }
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        
        return collectionView
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
    
    // 自定义初始化方法
    init(delegate: SJZPageListContainerViewDelegate?) {
        super.init(frame: .zero)
        
        self.delegate = delegate
        isFirstLayoutSubviews = true
        self.addSubview(collectionView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.collectionView.frame != self.bounds {
            self.collectionView.frame = self.bounds
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.reloadData()
        }
        
        if let selectedIndexPath = self.selectedIndexPath,
           let function = self.delegate?.numberOfRows(_:),
           function(self) > selectedIndexPath.item + 1 {
            self.collectionView.scrollToItem(at: selectedIndexPath, at: UICollectionView.ScrollPosition(), animated: false)
        }
        
        if isFirstLayoutSubviews {
            isFirstLayoutSubviews = false
            
            self.collectionView.setContentOffset(CGPoint(x: self.collectionView.bounds.size.width * CGFloat(self.defaultSelectedIndex), y: 0), animated: false)
        }
    }
    
    func reloadData() {
        self.collectionView.reloadData()
    }
    
    func deviceOrientationDidChange() {
        if self.bounds.size.width > 0 {
            self.selectedIndexPath = IndexPath(item: Int(self.collectionView.contentOffset.x / self.bounds.size.width), section: 0)
        }
    }
}

extension SJZPageListContainerView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let function = self.delegate?.numberOfRows(_:) else {
            return 0
        }
        
        return function(self)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        
        if let function = self.delegate?.pageList(_:listViewInRow:) {
            let listView = function(self, indexPath.item)
            listView.frame = cell.bounds
            cell.contentView.addSubview(listView)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.delegate?.pageList(self, willDisplayCellAtRow: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.delegate?.pageList(self, didEndDisplayingCellAtRow: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.mainTableView?.isScrollEnabled = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.mainTableView?.isScrollEnabled = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.mainTableView?.isScrollEnabled = true
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.mainTableView?.isScrollEnabled = true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.bounds.size
    }
}
