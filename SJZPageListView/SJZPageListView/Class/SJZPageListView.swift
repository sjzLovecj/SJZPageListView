//
//  SJZPageListView.swift
//  SJZPageListView
//
//  Created by SJZ on 2021/8/23.
//

import UIKit
import JXSegmentedView

@objc protocol SJZPageListViewDelegate {
    // MARK: - UISCrollView代理
    @objc optional
    func pageListViewDidScroll(_ scrollView: UIScrollView)
    
    @objc optional
    func pageListViewWillBeginDragging(_ scrollView: UIScrollView)
    
    @objc optional
    func pageListViewDidEndDecelerating(_ scrollView: UIScrollView)
    
    @objc optional
    func pageListViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    
    // MARK: - tableView代理
    @objc optional
    func pageListViewNumberOfSections(in tableView: UITableView)
    
    @objc optional
    func pageListView(_ tableView: UITableView, sectionData: SJZPageListSectionData, numberOfRowsInSection section: Int)
    
    @objc
    func pageListView(_ tableView: UITableView, listCellData: SJZPageListCellData, cellForRowAt indexPath: IndexPath) -> UITableViewCell?
    
    @objc optional
    func pageListView(_ tableView: UITableView, listCellData: SJZPageListCellData?,heightForRowAt indexPath: IndexPath)
    
    @objc optional
    func pageListView(_ tableView: UITableView, listCellData: SJZPageListCellData, didSelectRowAt indexPath: IndexPath)
    
    @objc optional
    func pageListView(_ tableView: UITableView, sectionData: SJZPageListSectionData, heightForHeaderInSection section: Int)
    
    @objc optional
    func pageListView(_ tableView: UITableView, sectionData: SJZPageListSectionData, viewForHeaderInSection section: Int) -> UIView?
    
    @objc optional
    func pageListView(_ tableView: UITableView, sectionData: SJZPageListSectionData, heightForFooterInSection section: Int)
    
    @objc optional
    func pageListView(_ tableView: UITableView, sectionData: SJZPageListSectionData, viewForFooterInSection section: Int) -> UIView?
}

class SJZPageListView: UIView {
    static let cellIdentifier = "cellIdentifier"
    
    public var configure: SJZPageListConfigure = SJZPageListConfigure()

    public var categoryView: JXSegmentedView {
        get {
            return segmentedView
        }

        set {
            segmentedView = newValue
            segmentedView.delegate = self
            segmentedView.contentScrollView = self.listContainerView.collectionView
        }
    }
    
    public var isScrollEnabled: Bool = true {
        didSet {
            self.mainTableView.isScrollEnabled = isScrollEnabled
        }
    }
    
    public var tableView: UITableView {
        return mainTableView
    }
    
    fileprivate var segmentedView: JXSegmentedView = JXSegmentedView()
    fileprivate weak var delegate: SJZPageListViewDelegate?
    fileprivate var listContainerCell: UITableViewCell = UITableViewCell()
    fileprivate var currentScrollingView: UIScrollView?
    
    fileprivate lazy var mainTableView: SJZPageMainTableView = {
        let mainTableView = SJZPageMainTableView(frame: .zero, style: .plain)
        mainTableView.showsVerticalScrollIndicator = false
        mainTableView.backgroundColor = UIColor.white
        mainTableView.separatorStyle = .none
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.gestureDelegate = self
        mainTableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: SJZPageListView.cellIdentifier)
        
        if #available(iOS 11.0, *) {
            mainTableView.contentInsetAdjustmentBehavior = .never
        }
        
        return mainTableView
    }()
    
    fileprivate lazy var listContainerView: SJZPageListContainerView = {
        let listContainerView = SJZPageListContainerView(delegate: self)
        listContainerView.mainTableView = self.mainTableView
        return listContainerView
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
    init(delegate: SJZPageListViewDelegate?) {
        super.init(frame: .zero)
        
        self.delegate = delegate
        addSubview(self.mainTableView)
        
        segmentedView.delegate = self
        segmentedView.contentScrollView = self.listContainerView.collectionView
        
        configListViewDidScrollCallBack()
    }
    
    // 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.mainTableView.frame = self.bounds
    }
    
    // 注册Cell
    public func register(cellClass: AnyClass?, forCellReuseIdentifier: String) {
        self.mainTableView.register(cellClass, forCellReuseIdentifier: forCellReuseIdentifier)
    }
    
    // 刷新数据
    public func reloadData() {
        self.configure.listViewArr.forEach({ view in
            view.removeFromSuperview()
        })
        
        configListViewDidScrollCallBack()
        
        self.mainTableView.reloadData()
        self.listContainerView.reloadData()
        self.categoryView.reloadData()
    }
    
    public func mainTableViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 10 {
            scrollView.bounces = false
        }else {
            scrollView.bounces = true
        }
        
        let topContentY = mainTableViewMaxContentOffsetY()
        if scrollView.contentOffset.y >= topContentY {
            if self.categoryView.superview != self {
                var frame = categoryView.frame
                frame.origin.y = configure.pinSegmentVerticalOffset
                self.categoryView.frame = frame
                self.addSubview(categoryView)
            }
        }else if categoryView.superview != self.listContainerCell.contentView {
            var frame = categoryView.frame
            frame.origin.y = 0
            categoryView.frame = frame
            listContainerCell.contentView.addSubview(categoryView)
        }
        
        if scrollView.isTracking || scrollView.isDecelerating {
            if let listView = self.currentScrollingView, listView.contentOffset.y > 0 {
                self.mainTableView.contentOffset = CGPoint(x: 0, y: topContentY)
            }
        }
        
        if !self.configure.isListViewScrollStateSaveEnabled {
            if scrollView.contentOffset.y < topContentY {
                var insetTop = scrollView.contentInset.top
                if #available(iOS 11.0, *) {
                    insetTop = scrollView.adjustedContentInset.top
                }
                
                self.configure.listViewArr.forEach({ listView in
                    listView.listScrollView().contentOffset = CGPoint(x: 0, y: -insetTop)
                })
            }
        }
    }
    
    public func listContainerCellHeight() -> CGFloat {
        return self.bounds.size.height - configure.pinSegmentVerticalOffset
    }
    
    public func mainTableViewMaxContentOffsetY() -> CGFloat {
        return floor(self.mainTableView.contentSize.height) - self.bounds.size.height
    }
    
    func configListViewDidScrollCallBack() {
        self.configure.listViewArr.forEach({ listView in
            listView.listViewDidScrollCallback { [weak self] scrollView in
                self?.listViewDidScroll(scrollView: scrollView)
            }
        })
    }
    
    func listViewDidScroll(scrollView: UIScrollView) {
        self.currentScrollingView = scrollView
        
        if scrollView.isTracking == false && scrollView.isDecelerating == false {
            return
        }
        
        let topContentHeight = self.mainTableViewMaxContentOffsetY()
        if self.mainTableView.contentOffset.y < topContentHeight {
            var insetTop = scrollView.contentInset.top
            if #available(iOS 11.0, *) {
                insetTop = scrollView.adjustedContentInset.top
            }
            scrollView.contentOffset = CGPoint(x: 0, y: -insetTop)
        }else {
            self.mainTableView.contentOffset = CGPoint(x: 0, y: topContentHeight)
        }
    }
    
    func listContainerCellForRow(at indexPath: IndexPath) -> UITableViewCell {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            if !self.configure.listViewArr.isEmpty,
               self.categoryView.selectedIndex < self.configure.listViewArr.count {
                self.configure.listViewArr[self.categoryView.selectedIndex].listViewLoadDataIfNeeded()
            }
        }
        
        let cell = self.mainTableView.dequeueReusableCell(withIdentifier: SJZPageListView.cellIdentifier, for: indexPath)
        cell.selectionStyle = .none
        self.listContainerCell = cell
        
        cell.contentView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        
        self.categoryView.frame = CGRect(x: 0, y: 0, width: cell.contentView.bounds.size.width, height: self.configure.categoryViewHeight)
        if(self.categoryView.superview != cell.contentView) {
            cell.contentView.addSubview(self.categoryView)
        }
        
        self.listContainerView.frame = CGRect(x: 0, y: self.configure.categoryViewHeight, width: cell.contentView.bounds.size.width, height: cell.contentView.bounds.size.height - self.configure.categoryViewHeight)
        cell.contentView.addSubview(self.listContainerView)
        
        return cell
    }
}

// MARK: - 实现 JXSegmentedViewDelegate 代理
extension SJZPageListView: JXSegmentedViewDelegate {
    func listViewDidSelected(at Index: NSInteger) {
        if Index < self.configure.listViewArr.count {
            let listContainerView = self.configure.listViewArr[Index]
            if listContainerView.listScrollView().contentOffset.y > 0 {
                self.mainTableView.setContentOffset(CGPoint(x: 0, y: mainTableViewMaxContentOffsetY()), animated: true)
            }
        }
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if index < self.configure.listViewArr.count {
            self.configure.listViewArr[index].listViewLoadDataIfNeeded()
        }
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, didClickSelectedItemAt index: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.listViewDidSelected(at: index)
        }
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, didScrollSelectedItemAt index: Int) {
        self.listViewDidSelected(at: index)
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, canClickItemAt index: Int) -> Bool {
        return true
    }
    
    
    func segmentedView(_ segmentedView: JXSegmentedView, scrollingFrom leftIndex: Int, to rightIndex: Int, percent: CGFloat) {
        
    }
}

// MARK: - 实现 SJZPageListContainerViewDelegate 代理
extension SJZPageListView: SJZPageListContainerViewDelegate {
    func numberOfRows(_ listcontainerView: SJZPageListContainerView) -> NSInteger {
        return self.configure.listViewArr.count
    }
    
    func pageList(_ containerView: SJZPageListContainerView, listViewInRow row: NSInteger) -> UIView {
        if row < self.configure.listViewArr.count {
            return self.configure.listViewArr[row]
        }
        
        return UIView()
    }
    
    func pageList(_ containerView: SJZPageListContainerView, willDisplayCellAtRow row: NSInteger) {
        if row  < self.configure.listViewArr.count {
            self.currentScrollingView = self.configure.listViewArr[row].listScrollView()
        }
    }
    
    func pageList(_ containerView: SJZPageListContainerView, didEndDisplayingCellAtRow row: NSInteger) {
        
    }
}

// MARK: - 实现 UITableViewDelegate, UITableViewDataSource 代理
extension SJZPageListView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let function = self.delegate?.pageListViewNumberOfSections(in:) {
             function(tableView)
        }
        
        return self.configure.sectionArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionData = SJZPageProcessData.getSectionData(sectionArr: self.configure.sectionArr, section: section) else {
            return 0
        }
        
        if let function = self.delegate?.pageListView(_:sectionData:numberOfRowsInSection:) {
            function(tableView, sectionData, section)
        }
        
        if sectionData.isLastSection {
            return 1
        }else {
            return sectionData.cellDataArr.count
        }
    }
    
    // 这里处理的不完美，因为最后一个没有CellData
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let sectionData = SJZPageProcessData.getSectionData(sectionArr: self.configure.sectionArr, section: indexPath.section) else {
            return 0
        }
        
        if sectionData.isLastSection {
            if let function = self.delegate?.pageListView(_:listCellData:heightForRowAt:) {
                function(tableView, nil, indexPath)
            }
            return self.listContainerCellHeight()
        }
        
        guard let cellData = SJZPageProcessData.getCellData(sectionData: sectionData, row: indexPath.row) else {
            return 0
        }
        
        if let function = self.delegate?.pageListView(_:listCellData:heightForRowAt:) {
            function(tableView, cellData, indexPath)
        }
        
        return cellData.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 判断sectionArr，是否为nil
        guard let sectionData = SJZPageProcessData.getSectionData(sectionArr: self.configure.sectionArr, section: indexPath.section) else {
            return SJZPageProcessData.getNullCell()
        }
        
        if sectionData.isLastSection,
           indexPath.section + 1 == self.configure.sectionArr.count,
           self.configure.listViewArr.count > 0 {
            return self.listContainerCellForRow(at: indexPath)
        }else {
            sectionData.isLastSection = false
        }
        
        // 判断 cellDataArr 是否为 nil
        guard let cellData = SJZPageProcessData.getCellData(sectionData: sectionData, row: indexPath.row) else {
            return SJZPageProcessData.getNullCell()
        }
        
        if let function = self.delegate?.pageListView(_:listCellData:cellForRowAt:),
            let cell = function(tableView, cellData, indexPath) {
            cell.selectionStyle = .none
            return cell
        }
        
        return SJZPageProcessData.getNullCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cellData = SJZPageProcessData.getCellData(sectionArr: self.configure.sectionArr, indexPath: indexPath) else {
            return
        }
        
        self.delegate?.pageListView?(tableView, listCellData: cellData, didSelectRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionData = SJZPageProcessData.getSectionData(sectionArr: self.configure.sectionArr, section: section) else {
            return 0.01
        }
        
        if sectionData.isHaveHeader {
            if let function = self.delegate?.pageListView(_:sectionData:heightForHeaderInSection:) {
                function(tableView, sectionData, section)
            }
            return sectionData.headerHeight
        }
        
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionData = SJZPageProcessData.getSectionData(sectionArr: self.configure.sectionArr, section: section) else {
            return UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 0.01))
        }
        
        if sectionData.isHaveHeader {
            if let function = self.delegate?.pageListView(_:sectionData:viewForHeaderInSection:) {
                return function(tableView, sectionData, section)
            }
        }
        
        return UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 0.01))
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let sectionData = SJZPageProcessData.getSectionData(sectionArr: self.configure.sectionArr, section: section) else {
            return 0.01
        }
        
        if sectionData.isHaveFooter {
            if let function = self.delegate?.pageListView(_:sectionData:heightForFooterInSection:) {
                function(tableView, sectionData, section)
            }
            return sectionData.footerHeight
        }
        
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let sectionData = SJZPageProcessData.getSectionData(sectionArr: self.configure.sectionArr, section: section) else {
            return UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 0.01))
        }
        
        if sectionData.isHaveFooter {
            if let function = self.delegate?.pageListView(_:sectionData:viewForFooterInSection:) {
                return function(tableView, sectionData, section)
            }
        }

        return UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 0.01))
    }
}

//MARK: - 实现ScrollView代理
extension SJZPageListView {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        mainTableViewDidScroll(scrollView: scrollView)
        if let function = self.delegate?.pageListViewDidScroll(_:) {
            function(scrollView)
        }
    }
    
    // 开始拖动
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let function = self.delegate?.pageListViewWillBeginDragging(_:) {
            function(scrollView)
        }
    }
    
    // 结束拖动
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let function = self.delegate?.pageListViewDidEndDragging(_:willDecelerate:) {
            function(scrollView, decelerate)
        }
    }
    
    // 开始减速
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if let function = self.delegate?.pageListViewWillBeginDragging(_:) {
            function(scrollView)
        }
    }
    
    // 减速停止
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let function = self.delegate?.pageListViewDidEndDecelerating(_:) {
            function(scrollView)
        }
    }
}

// 解决手势冲突
extension SJZPageListView: SJZPageMainTableViewGestureDelegate {
    func mainTableGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let controller = self.delegate as? UIViewController,
           (gestureRecognizer == controller.navigationController?.interactivePopGestureRecognizer ||
            otherGestureRecognizer == controller.navigationController?.interactivePopGestureRecognizer){
            return false
        }
        
        return gestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder()) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder())
    }
}
