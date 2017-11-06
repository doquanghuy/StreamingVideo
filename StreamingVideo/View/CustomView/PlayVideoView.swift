//
//  PlayVideoView.swift
//  StreamingVideo
//
//  Created by huydoquang on 11/4/17.
//  Copyright © 2017 huydoquang. All rights reserved.
//

import UIKit

protocol PlayControl {
    static func add(on view: UIView, delegate: PlayControlOutput, animated: Bool) -> UIView
    func hide(animated: Bool)
}

protocol PlayControlOutput: class {
    func playOrPause(isPlay: Bool)
}

fileprivate class PlayVideoViewOwner: NSObject {
    @IBOutlet var playVideoView: PlayVideoView!
}

class PlayVideoView: UIView, PlayControl {
    private weak var delegate: PlayControlOutput?
    private var isPlaying = false {
        didSet {
            let imageName = isPlaying ? Constants.Image.pause : Constants.Image.play
            self.playButton.setImage(UIImage(named: imageName), for: .normal)
            self.delegate?.playOrPause(isPlay: self.isPlaying)
        }
    }
    private var hide: Bool = false {
        didSet {
            self.alpha = hide ? 0.0 : 1.0
        }
    }
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBAction func playOrPause(_ sender: Any) {
        self.isPlaying = !self.isPlaying
    }
    
    @objc fileprivate func touchToPlayOrPause(gesture: UITapGestureRecognizer) {
        
        self.isPlaying = !self.isPlaying
    }

    static func add(on view: UIView, delegate: PlayControlOutput, animated: Bool) -> UIView {
        let owner = PlayVideoViewOwner()
        Bundle.main.loadNibNamed(String(describing: self), owner: owner, options: nil)
        owner.playVideoView.delegate = delegate
        view.addSubview(owner.playVideoView)
        
        let tapGesrture = UITapGestureRecognizer(target: owner.playVideoView, action: #selector(PlayVideoView.touchToPlayOrPause(gesture:)))
        owner.playVideoView.addGestureRecognizer(tapGesrture)
        
        owner.playVideoView.alpha = 0.0
        let views = ["playVideoView": owner.playVideoView] as [String: Any]
        owner.playVideoView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstrains = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[playVideoView]-0-|", options: [], metrics: nil, views: views)
        let verticalConstrains = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[playVideoView]-0-|", options: [], metrics: nil, views: views)
        view.addConstraints(horizontalConstrains)
        view.addConstraints(verticalConstrains)
        view.layoutIfNeeded()
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                owner.playVideoView.alpha = 1.0
            })
        } else {
            owner.playVideoView.alpha = 1.0
        }
        return owner.playVideoView
    }
    
    func hide(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.hide = true
            })
        } else {
            self.hide = true
        }
    }
}
