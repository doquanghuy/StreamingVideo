//
//  Ext+UITableView.swift
//  StreamingVideo
//
//  Created by huydoquang on 10/31/17.
//  Copyright © 2017 huydoquang. All rights reserved.
//

import UIKit

enum RegisterCellType {
    case classType, nibType
}
extension UICollectionView {
    func register(type: RegisterCellType, with cellClass: AnyClass) {
        let identifier = String(describing: cellClass)
        switch type {
        case .classType:
            self.register(cellClass, forCellWithReuseIdentifier: identifier)
        default:
            let nib = UINib(nibName: identifier, bundle: nil)
            self.register(nib, forCellWithReuseIdentifier: identifier)
        }
    }
}
