//
//  SJZPageListConfigure.swift
//  SJZTJBHomeModule
//
//  Created by SJZ on 2021/8/26.
//

import UIKit

protocol SJZPageListViewListDelegate where Self: UIView {
    // 必须在类中实现，生成实例属性。在闭包中会生成 计算属性
    var scrollCallback: ((UIScrollView) -> ())? { get set }
    func listScrollView() -> UIScrollView
    func listViewLoadDataIfNeeded()
}

extension SJZPageListViewListDelegate {
    func listViewDidScrollCallback(scrollCallback: @escaping (UIScrollView) -> ()) {
        self.scrollCallback = scrollCallback
    }
}

class SJZPageListConfigure {
    public var pinSegmentVerticalOffset: CGFloat = 0
    
    public var categoryViewHeight: CGFloat = 0
    
    public var isListViewScrollStateSaveEnabled = true
    
    public var sectionArr: [SJZPageListSectionData] = []
    
    public var listViewArr: [SJZPageListViewListDelegate] = []
}

class SJZPageListSectionData: NSObject {
    public var sectionType: Any?
    
    public var isLastSection = false
    
    // 是否有 header 和 header 高度
    // 如果 isHaveHeader 为true，那么是否headerHeight大于零，都不会展示headerView
    public var isHaveHeader = false
    public var headerHeight: CGFloat = 0
    
    // 是否有 footer 和 footer 高度
    // 如果 isHaveFooter 为true，那么是否footerHeight大于零，都不会展示footerView
    public var isHaveFooter = false
    public var footerHeight: CGFloat = 0
    
    public var cellDataArr: [SJZPageListCellData] = []
}

class SJZPageListCellData: NSObject {
    public var cellType: Any?
    
    // Cell的高度
    public var cellHeight: CGFloat = 0
    // Cell的数据，可以为任何类型，对象、数组、字典等
    public var cellData: Any?
    
    // 是否为最后一个Cell
    public var isLastCell: Bool = false
}
