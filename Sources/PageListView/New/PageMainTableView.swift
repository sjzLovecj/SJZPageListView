//
//  PageMainTableView.swift
//  SJZPageListView
//
//  Created by S JZ on 2023/5/29.
//

import UIKit

@objc public protocol PageMainTableViewGestureDelegate {
    @objc optional func mainTableGestureRecognize(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
}

//class PageMainTableView: UITableView, UIGestureRecognizerDelegate {
//    weak var gestureDelegate: PageMainTableViewGestureDelegate?
//
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if let function = gestureDelegate?.mainTableGestureRecognize(_:shouldRecognizeSimultaneouslyWith:) {
//            return function(gestureRecognizer, otherGestureRecognizer)
//        }else {
//            return gestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder()) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder())
//        }
//    }
//}

class PageMainCollectionView: UICollectionView, UIGestureRecognizerDelegate{
    weak var gestureDelegate: PageMainTableViewGestureDelegate?

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let function = gestureDelegate?.mainTableGestureRecognize(_:shouldRecognizeSimultaneouslyWith:) {
            return function(gestureRecognizer, otherGestureRecognizer)
        }else {
            return gestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder()) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder())
        }
    }
}


