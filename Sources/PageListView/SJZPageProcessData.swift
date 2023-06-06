//
//  SJZPageProcessData.swift
//  SJZTJBHomeModule
//
//  Created by SJZ on 2021/9/3.
//

import UIKit

class SJZPageProcessData: NSObject {
    class func getNullCell() -> UITableViewCell {
        let nullCell = UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
        nullCell.selectionStyle = .none
        return nullCell
    }
    
    class func getCellData(sectionArr: [SJZPageListSectionData], indexPath: IndexPath) -> SJZPageListCellData? {
        guard let sectionData = SJZPageProcessData.getSectionData(sectionArr: sectionArr, section: indexPath.section) else {
            return nil
        }
        
        guard let cellData = SJZPageProcessData.getCellData(sectionData: sectionData, row: indexPath.row) else {
            return nil
        }
        
        return cellData
    }
    
    
    class func getCellData(sectionData: SJZPageListSectionData, row: Int) -> SJZPageListCellData? {
        if row < 0 {
            return nil
        }
        
        // 防止 sectionData.cellDataArr 为 nil 与越界
        if row < sectionData.cellDataArr.count {
            let cellData = sectionData.cellDataArr[row]
            
            // 设置最后一个Cell
            cellData.isLastCell = false
            if sectionData.cellDataArr.count == row + 1 {
                cellData.isLastCell = true
            }
            
            return cellData
        }
        
        return nil
    }
    
    class func getSectionData(sectionArr: [SJZPageListSectionData], section: Int) -> SJZPageListSectionData? {
        if section < 0 {
            return nil
        }
        
        if section < sectionArr.count {
            return sectionArr[section]
        }
        
        return nil
    }
    
}
