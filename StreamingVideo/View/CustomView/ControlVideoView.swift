//
//  ControlVideoView.swift
//  StreamingVideo
//
//  Created by huydoquang on 10/30/17.
//  Copyright © 2017 huydoquang. All rights reserved.
//

import UIKit

enum Loop {
    case none, one, forever
    
    func next() -> Loop {
        switch self {
        case .none:
            return .one
        case .one:
            return .forever
        default:
            return .none
        }
    }
}

protocol FullControlOutput: class, PlayControlOutput {
    func download()
    func setLoop(type: Loop)
    func slide(to value: Float)
}

protocol FullControl {
    static func add(on view: UIView, delegate: FullControlOutput, animated: Bool) -> UIView
    func hide(delay: Double, animated: Bool, completion: (() -> Void)?)
    func show(animated: Bool, completion: (() -> Void)?)
    func setSlider(to value: Float, animated: Bool)
    func setTotalDuration(to value: String)
    func setCurrentTime(to value: String)
    func changePlayButton(isPlay: Bool)
}

class ControlVideoViewOwner: NSObject {
    @IBOutlet var controlVideoView: ControlVideoView!
}

final class ControlVideoView: UIView, FullControl {
    private weak var delegate: FullControlOutput?
    
    private var loop = Loop.none {
        didSet {
            delegate?.setLoop(type: self.loop)
        }
    }
    private var isPlaying = false {
        didSet {
            delegate?.playOrPause(isPlay: self.isPlaying)
        }
    }
    
    private var hide: Bool = false
    private var currentDispatchWorkItem: DispatchWorkItem?
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var loopButton: UIButton!
    @IBOutlet weak var rightTimeLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var leftTimeLabel: UILabel!
    
    @IBAction func clickLoop(_ sender: Any) {
        self.loop = self.loop.next()
    }
    
    @IBAction func clickDownload(_ sender: Any) {
        delegate?.download()
    }
    
    @IBAction func slide(_ sender: Any) {
        let slider = sender as! UISlider
        delegate?.slide(to: slider.value)
    }
    
    @IBAction func playOrPause(_ sender: Any) {
        self.isPlaying = !self.isPlaying
    }
    
    @objc fileprivate func touchToPlayOrPause(gesture: UITapGestureRecognizer) {
        if self.hide {
            self.show(animated: true)
            self.hide(delay: 5.0, animated: true)
        } else {
            self.currentDispatchWorkItem?.cancel()
            self.hide(animated: true)
        }
    }
    
    static func add(on view: UIView, delegate: FullControlOutput, animated: Bool) -> UIView {
        let owner = ControlVideoViewOwner()
        Bundle.main.loadNibNamed(String(describing: self), owner: owner, options: nil)
        owner.controlVideoView.delegate = delegate
        view.addSubview(owner.controlVideoView)

        let tapGesrture = UITapGestureRecognizer(target: owner.controlVideoView, action: #selector(ControlVideoView.touchToPlayOrPause(gesture:)))
        owner.controlVideoView.addGestureRecognizer(tapGesrture)
        let views = ["controlVideoView": owner.controlVideoView] as [String: Any]
        owner.controlVideoView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstrains = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[controlVideoView]-0-|", options: [], metrics: nil, views: views)
        let verticalConstrains = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[controlVideoView]-0-|", options: [], metrics: nil, views: views)
        view.addConstraints(horizontalConstrains)
        view.addConstraints(verticalConstrains)
        view.layoutIfNeeded()
        owner.controlVideoView.hide(delay: 5.0, animated: true)
        return owner.controlVideoView
    }
    
    func hide(delay: Double = 0.0, animated: Bool, completion: (() -> Void)? = nil) {
        let hideClosureNotAnimation = {[weak self] in
            self?.topView.alpha = 0.0
            self?.bottomView.alpha = 0.0
            self?.playButton.alpha = 0.0
            self?.hide = true
        }
        
        let hideClosureAnimation = {
            UIView.animate(withDuration: 0.3, animations: hideClosureNotAnimation)
        }

        guard animated else {
            hideClosureNotAnimation()
            return
        }
        
        guard delay > 0.0 else {
            hideClosureAnimation()
            return
        }
        
        self.currentDispatchWorkItem = DispatchWorkItem(block: hideClosureAnimation)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: currentDispatchWorkItem!)
    }
    
    func show(animated: Bool, completion: (() -> Void)? = nil) {
        let showClosure = {[weak self] in
            self?.topView.alpha = 1.0
            self?.bottomView.alpha = 1.0
            self?.playButton.alpha = 1.0
            self?.hide = false
        }
        
        guard animated else {
            showClosure()
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            showClosure()
            completion?()
        }
    }
    
    func setSlider(to value: Float, animated: Bool) {
        self.slider.setValue(value, animated: true)
    }
    
    func setTotalDuration(to value: String) {
        self.rightTimeLabel.text = value
    }
    
    func setCurrentTime(to value: String) {
        self.leftTimeLabel.text = value
    }
    
    func changePlayButton(isPlay: Bool) {
        let imageName = isPlay ? Constants.Image.pause : Constants.Image.play
        self.playButton.setImage(UIImage(named: imageName), for: .normal)
    }
}

