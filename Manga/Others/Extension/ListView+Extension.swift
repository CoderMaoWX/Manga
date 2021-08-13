//
//  CollectionView+Extention.swift
//  Manga
//
//  Created by 610582 on 2021/8/13.
//

import Foundation
import UIKit

extension UITableView {
    
    ///刷新时是否需要动画
    func reloadData(animation: Bool = true) {
        if animation {
            reloadData()
        } else {
            UIView.performWithoutAnimation {
                reloadData()
            }
        }
    }
}

extension UICollectionView {
    
    ///刷新时是否需要动画
    func reloadData(animation: Bool = true) {
        if animation {
            reloadData()
        } else {
            UIView.performWithoutAnimation {
                reloadData()
            }
        }
    }
}
