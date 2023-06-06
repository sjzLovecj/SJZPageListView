//
//  SJZPageMainTableView.swift
//  SJZPageListView
//
//  Created by SJZ on 2021/8/23.
//

import UIKit

@objc public protocol SJZPageMainTableViewGestureDelegate {
    @objc optional func mainTableGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
}

class SJZPageMainTableView: UITableView, UIGestureRecognizerDelegate {

    weak var gestureDelegate: SJZPageMainTableViewGestureDelegate?
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let function = gestureDelegate?.mainTableGestureRecognizer(_:shouldRecognizeSimultaneouslyWith:) {
            return function(gestureRecognizer, otherGestureRecognizer)
        }else {
            return gestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder()) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder())
        }
    }
    
}
