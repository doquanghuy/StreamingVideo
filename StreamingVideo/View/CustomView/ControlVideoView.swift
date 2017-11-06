//
//  ControlVideoView.swift
//  StreamingVideo
//
//  Created by huydoquang on 10/30/17.
//  Copyright © 2017 huydoquang. All rights reserved.
//

import UIKit

enum Loop {
    case none
    case one
    case forever
    
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
    
    func imageName() -> String {
        switch self {
        case .forever:
            return Constants.Image.loopForever
        case .one:
            return Constants.Image.loopOne
        default:
            return Constants.Image.unloop
        }
    }
}

protocol FullControlOutput: class, PlayControlOutput {
    func download()
    func setLoop(type: Loop)
    func sliderTouchUpInside(slider: UISlider)
    func sliderTouchUpOutside(slider: UISlider)
    func sliderTouchDown(slider: UISlider)
}

protocol FullControl {
    static func add(on view: UIView, delegate: FullControlOutput, animated: Bool, isOffline: Bool) -> UIView
    func hide(delay: Double, animated: Bool, completion: (() -> Void)?)
    func show(animated: Bool, completion: (() -> Void)?)
    func setSlider(to value: Float, animated: Bool)
    func setTotalDuration(to value: String)
    func setCurrentTime(to value: String)
    func changePlayButton(isPlay: Bool)
    func changeLoopButton(with loop: Loop)
    func progressView(to value: Float)
    func completeLoading(with error: NSError?)
}

class ControlVideoViewOwner: NSObject {
    @IBOutlet var controlVideoView: ControlVideoView!
}

final class ControlVideoView: UIView, FullControl {
    private weak var delegate: FullControlOutput?
    
    private var loop = Loop.none {
        didSet {
            self.loopButton.setImage(UIImage(named:  loop.imageName()), for: .normal)
            self.delegate?.setLoop(type: self.loop)
        }
    }
    private var isPlaying = false {
        didSet {
            let imageName = isPlaying ? Constants.Image.play : Constants.Image.pause
            self.playButton.setImage(UIImage(named: imageName), for: .normal)
            self.delegate?.playOrPause(isPlay: self.isPlaying)
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
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var completionLabel: UILabel!
    @IBAction func clickLoop(_ sender: Any) {
        self.loop = self.loop.next()
    }
    
    @IBAction func clickDownload(_ sender: Any) {
        self.delegate?.download()
    }
    
    @IBAction func playOrPause(_ sender: Any) {
        self.isPlaying = !self.isPlaying
    }
    
    @IBAction func processWhenSliderTouchDown(_ sender: Any) {
        self.delegate?.sliderTouchDown(slider: sender as! UISlider)
    }
    
    @IBAction func processWhenSliderTouchUpInside(_ sender: Any) {
        self.delegate?.sliderTouchUpInside(slider: sender as! UISlider)
    }
    
    @IBAction func processWhenSliderTouchUpOutside(_ sender: Any) {
        self.delegate?.sliderTouchUpOutside(slider: sender as! UISlider)
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
    
    static func add(on view: UIView, delegate: FullControlOutput, animated: Bool, isOffline: Bool = false) -> UIView {
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
            self?.progressView.alpha = 0.0
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
            self?.progressView.alpha = 1.0
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
    
    func progressView(to value: Float) {
        self.progressView.isHidden = false
        self.progressView.setProgress(value, animated: true)
    }
    
    func completeLoading(with error: NSError?) {
        self.progressView.isHidden = true
        self.completionLabel.text = error == nil ? Constants.String.downloadComplete : error!.localizedDescription
        self.completionLabel.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.completionLabel.isHidden = true
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
    
    func changeLoopButton(with loop: Loop) {
        self.loopButton.setImage(UIImage(named: loop.imageName()), for: .normal)
    }
}
