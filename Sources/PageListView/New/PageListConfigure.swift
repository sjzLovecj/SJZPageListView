//
//  PageListConfigure.swift
//  SJZPageListView
//
//  Created by S JZ on 2023/5/29.
//

import UIKit

public class PageListConfigure {
    // mainTableView中，section的数据数组
    public var sectionDataArr: [PageListSectionData] = []
    
    
    // SegmentView 的位置，默认为0
    public var pinSegmentVerticalOffset: CGFloat = 0
    // SegmentView 的高度
    public var segmentHeight: CGFloat = 0
    
    public var segmentListViewArr: [UIView] = []
}

public class PageListSectionData: NSObject {
    // section的标识
    public var sectionId: (any Equatable)?

    public var sectionEdgeInset: UIEdgeInsets = .zero
    public var lineSpacing: CGFloat = 0
    public var interitemSpacing: CGFloat = 0
    
    // 该Section是否有Header，如果为 false，那么将不显示header
    public var isHaveHeader: Bool = false
    // header的高度，如果想要展示header，isHaveHeader必须为true，且headerHeight给定适当高度
    public var headerHeight: CGFloat = 0.01
    
    // 该Section是否有fotter， 如果为 false，那么将不显示footer
    public var isHaveFooter: Bool = false
    // footer的高度，如果想要展示footer，isHaveFooter必须为true，且footerHeight给定适当高度
    public var footerHeight: CGFloat = 0.01
    
    // Section中，cell的数据数组
    public var cellDataArr: [PageListCellData] = []
}

public class PageListCellData: NSObject {
    // cell的标识
    public var itemId: (any Equatable)?

    public var itemSize: CGSize = .zero
    
    // cell的数据，为任意类型，对象、数组、字典等
    public var cellData: Any?
}

