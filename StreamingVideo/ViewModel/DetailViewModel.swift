//
//  DetailViewModel.swift
//  StreamingVideo
//
//  Created by huydoquang on 11/4/17.
//  Copyright © 2017 huydoquang. All rights reserved.
//

import Foundation
import AVFoundation

protocol DetailViewModelInterface {
    var didStartPlayVideo: Dynamic<Bool> {get set}
    var avPlayer: Dynamic<AVPlayer?> {get set}
    var timePassed: Dynamic<(String, Float)> {get set}
    var durationStr: Dynamic<String> {get set}
    func process()
}

class DetailViewModel: DetailViewModelInterface {
    var video: Video
    var avPlayer: Dynamic<AVPlayer?> = Dynamic<AVPlayer?>(nil)
    var timePassed: Dynamic<(String, Float)> = Dynamic<(String, Float)>(("0:0", 0.0))
    var durationStr: Dynamic<String> = Dynamic<String>("")
    var didStartPlayVideo: Dynamic<Bool> = Dynamic<Bool>(false)
    private var duration: Float = 0.0
    private var timeObserver: Any?
    
    init(video: Video) {
        self.video = video
    }
    
    func process() {
        guard let urlStr = video.streamURL, let url =  URL(string: urlStr) else {
            return
        }
        let avPlayer = AVPlayer(url: url)
        self.avPlayer.value = avPlayer
        self.processDuration(avPlayer: avPlayer)
        self.addObserver(avPlayer: avPlayer)
        self.didStartPlayVideo.value = true
        avPlayer.play()
    }
    
    private func processDuration(avPlayer: AVPlayer) {
        self.duration = Float(avPlayer.currentItem?.asset.duration.seconds ?? 0.0)
        self.durationStr.value = self.string(from: duration)
    }
    
    private func addObserver(avPlayer: AVPlayer) {
        let interval = CMTime(seconds: 0.05, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = avPlayer.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (cmTime) in
            let time = Float(CMTimeGetSeconds(cmTime))
            self.timePassed.value = (self.string(from: time), time / self.duration)
        })
    }
    
    private func string(from time: Float) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    deinit {
        self.avPlayer.value?.removeTimeObserver(self.timeObserver!)
    }
}


