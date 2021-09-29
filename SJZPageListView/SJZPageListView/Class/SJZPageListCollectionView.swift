//
//  SJZPageListCollectionView.swift
//  SJZPageListView
//
//  Created by SJZ on 2021/8/23.
//

import UIKit

@objc protocol SJZPageListCollectionViewDelegate {
    @objc optional func pageListCollectionView(_ collection: SJZPageListCollectionView, gestureRecognizerShouldBegin: UIGestureRecognizer) -> Bool
    @objc optional func pageListCollectionView(_ collection: SJZPageListCollectionView, gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
}

class SJZPageListCollectionView: UICollectionView, UIGestureRecognizerDelegate {
    var isNestEnabled = false
    
    weak var gestureDelegate: SJZPageListCollectionViewDelegate?

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let function = self.gestureDelegate?.pageListCollectionView(_:gestureRecognizerShouldBegin:) {
            return function(self, gestureRecognizer)
        }else {
            if self.isNestEnabled {
                if let gestureClass = NSClassFromString("UIScrollViewPanGestureRecognizer")?.class(),
                   gestureRecognizer.isMember(of: gestureClass),
                   let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
                    
                    let velocityX = panGesture.velocity(in: gestureRecognizer.view).x
                    
                    if velocityX > 0 {
                        if self.contentOffset.x == 0 {
                            return false
                        }
                    }else if velocityX < 0 {
                        if self.contentOffset.x + self.bounds.size.width == self.contentSize.width {
                            return false
                        }
                    }
                }
            }
        }
        
        return true
    }
    
    // 解决冲突
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let function = self.gestureDelegate?.pageListCollectionView(_:gestureRecognizer:shouldRecognizeSimultaneouslyWith:) else {
            return false
        }
        
        return function(self, gestureRecognizer, otherGestureRecognizer)
    }
}

