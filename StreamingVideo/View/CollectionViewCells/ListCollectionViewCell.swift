//
//  ListCollectionViewCell.swift
//  StreamingVideo
//
//  Created by huydoquang on 10/30/17.
//  Copyright © 2017 huydoquang. All rights reserved.
//

import UIKit
import AlamofireImage

protocol ListCollectionViewCellDelegate: class {
    func clickCell(video: Video)
}

class ListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    weak var delegate: ListCollectionViewCellDelegate?
    private var video: Video!
    
    func configure(with video: Video) {
        self.video = video
        let placeHolderImg = UIImage(named: "")
        if let urlStr = video.backgroundImageURL, let url = URL(string: urlStr) {
            self.imgView.af_setImage(withURL: url, placeholderImage: placeHolderImg)
        } else {
            self.imgView.image = placeHolderImg
        }
        self.nameLabel.text = video.name
        PlayVideoView.add(on: self, delegate: self, animated: true)
    }
}

extension ListCollectionViewCell: PlayControlOutput {
    func playOrPause(isPlay: Bool) {
        delegate?.clickCell(video: self.video)
    }
}
