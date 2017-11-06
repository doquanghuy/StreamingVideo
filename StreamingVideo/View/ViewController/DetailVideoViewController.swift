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
        Configuration.Orientation.orientation = UIInterfaceOrientationMask.allButUpsideDown
        self.setup()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
        
    private func setup() {
        viewModel.avPlayer.bind {[weak self] (avPlayer) in
            let avPlayerVC = AVPlayerViewController()
            avPlayerVC.showsPlaybackControls = false
            avPlayerVC.player = avPlayer
            
            //Add control view
            self?.addChildViewController(avPlayerVC)
            self?.containerVideoView.addSubview(avPlayerVC.view)
            avPlayerVC.view.translatesAutoresizingMaskIntoConstraints = false
            let views = ["avPlayerView": avPlayerVC.view] as [String: Any]
            let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[avPlayerView]-0-|", options: [], metrics: nil, views: views)
            let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[avPlayerView]-0-|", options: [], metrics: nil, views: views)
            self?.containerVideoView.addConstraints(horizontalConstraints)
            self?.containerVideoView.addConstraints(verticalConstraints)
            self?.view.layoutIfNeeded()
            if let controlView = self?.controlView as? UIView {
                self?.containerVideoView.bringSubview(toFront: controlView)
            }
        }
        viewModel.timePassed.bind {[weak self] (timeStr, percent) in
            self?.controlView.setCurrentTime(to: timeStr)
            self?.controlView.setSlider(to: percent, animated: true)
        }
        viewModel.durationStr.bind {[weak self] (duration) in
            self?.controlView.setTotalDuration(to: duration)
        }
        viewModel.loop.bind {[weak self](loop) in
            self?.controlView.changeLoopButton(with: loop)
        }
        viewModel.state.bind {[weak self] (state) in
            self?.controlView.changePlayButton(isPlay: state == .play)
        }
        viewModel.progress.bind {[weak self] (percent) in
            self?.controlView.progressView(to: Float(percent))
        }
        viewModel.downloadComplete.bind {[weak self] (result) in
            switch result {
            case .complete(let error):
                self?.controlView.completeLoading(with: error)
                break
            default:
                break
            }
        }
        viewModel.isOffline.bind {[weak self] (isOffline) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.controlView = ControlVideoView.add(on: strongSelf.containerVideoView, delegate: strongSelf, animated: true, isOffline: isOffline) as! FullControl
            strongSelf.containerVideoView.bringSubview(toFront: strongSelf.controlView as! UIView)
        }
        viewModel.fileExist.bind {[weak self] (isExisted) in
            if isExisted {
                let alert = UIAlertController(title: Constants.String.deleteTitle, message: nil, preferredStyle: .alert)
                let cancelButton = UIAlertAction(title: Constants.String.cancelButton, style: .cancel, handler: nil)
                let okButton = UIAlertAction(title: Constants.String.okButton, style: .default, handler: {(action) in
                    self?.viewModel.deleteFile()
                })
                alert.addAction(cancelButton)
                alert.addAction(okButton)
                self?.present(alert, animated: true, completion: nil)
            } else {
                self?.viewModel.download()
            }
        }
        viewModel.didDeleteFile.bind {[weak self] (didDeleteFile) in
            self?.delegate?.dismiss(animated: true)
        }
        viewModel.process()
    }
    
    @IBAction func clickCancelButton(_ sender: Any) {
        self.delegate?.dismiss(animated: true)
    }
}

extension DetailVideoViewController: FullControlOutput {
    func download() {
        viewModel.checkFileExist()
    }
    
    func setLoop(type: Loop) {
        viewModel.loop(with: type)
    }
        
    func sliderTouchUpInside(slider: UISlider) {
        viewModel.endSliding(at: slider.value)
    }
    
    func sliderTouchUpOutside(slider: UISlider) {
        viewModel.endSliding(at: slider.value)
    }
    
    func sliderTouchDown(slider: UISlider) {
        viewModel.beginSliding()
    }
    
    func playOrPause(isPlay: Bool) {
        isPlay ? self.viewModel.pause() : self.viewModel.play()
    }
}
