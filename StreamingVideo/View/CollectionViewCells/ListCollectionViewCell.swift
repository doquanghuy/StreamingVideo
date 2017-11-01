//
//  ListCollectionViewCell.swift
//  StreamingVideo
//
//  Created by huydoquang on 10/30/17.
//  Copyright © 2017 huydoquang. All rights reserved.
//

import UIKit
import AlamofireImage

class ListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    func configure(with video: Video) {
        let placeHolderImg = UIImage(named: "")
        if let urlStr = video.backgroundImageURL, let url = URL(string: urlStr) {
            self.imgView.af_setImage(withURL: url, placeholderImage: placeHolderImg)
        } else {
            self.imgView.image = placeHolderImg
        }
        self.nameLabel.text = video.name
    }
}
