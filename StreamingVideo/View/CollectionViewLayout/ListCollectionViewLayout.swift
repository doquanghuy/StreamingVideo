//
//  ListCollectionViewFlowLayout.swift
//  StreamingVideo
//
//  Created by huydoquang on 10/31/17.
//  Copyright © 2017 huydoquang. All rights reserved.
//

import UIKit

class ListCollectionViewLayout: UICollectionViewLayout {
    enum LayoutType {
        case single(Int)
        case double(Int, Int)
    }
    
    private let margin: CGFloat = 10.0
    private let heightOfCollectionViewItem: CGFloat =  100.0
    private var attributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var widthOfCollectionView: CGFloat!
    private var doubleWidth: CGFloat!
    private var doubleHeight: CGFloat!
    private var singleWidth: CGFloat!
    private var singleHeight: CGFloat!
    private var totalHeightOfOnePeriod: CGFloat!
    
    override func prepare() {
        guard let numberSection = collectionView?.numberOfSections, numberSection > 0 else {
            return
        }
        let numberItems = collectionView?.numberOfItems(inSection: 0) ?? 0
        self.calculateSize()
        for index in 0..<numberItems {
            let indexPath = IndexPath(row: index, section: 0)
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attribute.frame = self.position(at: index)
            attributes[indexPath] = attribute
        }
    }
    
    private func layout(at row: Int) -> LayoutType {
        let position = row % 3
        let level = row / 3
        
        switch position {
        case 0:
            return .double(0, level)
        case 1:
            return .double(1, level)
        default:
            return .single(level)
        }
    }
    
    private func calculateSize() {
        self.widthOfCollectionView = self.collectionView?.bounds.width ?? UIScreen.main.bounds.width
        
        self.doubleWidth = (widthOfCollectionView - 3.0 * margin) / 2.0
        self.doubleHeight = doubleWidth * 3.0 / 4.0
        
        self.singleWidth = widthOfCollectionView - 2.0 * margin
        self.singleHeight = self.singleWidth * 3.0 / 4.0
        
        self.totalHeightOfOnePeriod = doubleHeight + singleHeight + margin
    }
    
    private func position(at row: Int) -> CGRect {
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
        let layout = self.layout(at: row)
        
        switch layout {
        case .double(let index, let level):
            width = doubleWidth
            height = doubleHeight
            y = CGFloat(level) * totalHeightOfOnePeriod + margin * (CGFloat(level) + 1)
            if index == 0 {
                x = margin
            } else {
                x = 2.0 * margin + width
            }
        case .single(let level):
            width = singleWidth
            height = singleHeight
            x = margin
            y = CGFloat(level) * totalHeightOfOnePeriod + doubleHeight + margin * (CGFloat(level) + 2)
        }
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes[indexPath]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var allAttributes = [UICollectionViewLayoutAttributes]()
        for attribute in attributes.values {
            if attribute.frame.intersects(rect) {
                allAttributes.append(attribute)
            }
        }
        return allAttributes
    }
    
    override var collectionViewContentSize: CGSize {
        let numberItems = collectionView?.numberOfItems(inSection: 0) ?? 0
        let level = CGFloat((numberItems - 1) / 3 + 1)
        let contentHeight = level * totalHeightOfOnePeriod + margin * (level + 1)
        return CGSize(width: widthOfCollectionView, height: contentHeight)
    }
    
    override func invalidateLayout() {
        attributes.removeAll()
        super.invalidateLayout()
    }
}
