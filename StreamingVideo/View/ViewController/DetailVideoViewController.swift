//
//  DetailVideoViewController.swift
//  StreamingVideo
//
//  Created by huydoquang on 11/4/17.
//  Copyright © 2017 huydoquang. All rights reserved.
//

import UIKit
import AVKit

protocol DetailVideoViewControllerDelegate: class {
    func dismiss(animated: Bool)
}

class DetailVideoViewController: UIViewController {
    weak var delegate: DetailVideoViewControllerDelegate?
    var viewModel: DetailViewModelInterface!
    @IBOutlet weak var containerVideoView: UIView!
    var controlView: FullControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupData()
    }
    
    private func setupUI() {
        self.controlView = ControlVideoView.add(on: self.containerVideoView, delegate: self, animated: true) as! FullControl
    }
    
    private func setupData() {
        viewModel.avPlayer.bind { (avPlayer) in
            let avPlayerVC = AVPlayerViewController()
            avPlayerVC.showsPlaybackControls = false
            avPlayerVC.player = avPlayer
            
            //Add child vc
            self.addChildViewController(avPlayerVC)
            self.containerVideoView.addSubview(avPlayerVC.view)
            avPlayerVC.view.translatesAutoresizingMaskIntoConstraints = false
            let views = ["avPlayerView": avPlayerVC.view] as [String: Any]
            let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[avPlayerView]-0-|", options: [], metrics: nil, views: views)
            let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[avPlayerView]-0-|", options: [], metrics: nil, views: views)
            self.containerVideoView.addConstraints(horizontalConstraints)
            self.containerVideoView.addConstraints(verticalConstraints)
            self.view.layoutIfNeeded()
            self.containerVideoView.bringSubview(toFront: self.controlView as! UIView)
        }
        viewModel.timePassed.bind {(timeStr, percent) in
            self.controlView.setCurrentTime(to: timeStr)
            self.controlView.setSlider(to: percent, animated: true)
        }
        viewModel.durationStr.bind { (duration) in
            self.controlView.setTotalDuration(to: duration)
        }
        viewModel.didStartPlayVideo.bind { (didStart) in
            self.controlView.changePlayButton(isPlay: didStart)
        }
        viewModel.process()
    }
    
    @IBAction func clickCancelButton(_ sender: Any) {
        self.delegate?.dismiss(animated: true)
    }
}

extension DetailVideoViewController: FullControlOutput {
    func download() {
        
    }
    
    func setLoop(type: Loop) {
        
    }
    
    func slide(to value: Float) {
        
    }
    
    func playOrPause(isPlay: Bool) {
        
    }
}
