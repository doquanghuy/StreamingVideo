//
//  DetailViewModel.swift
//  StreamingVideo
//
//  Created by huydoquang on 11/4/17.
//  Copyright © 2017 huydoquang. All rights reserved.
//

import Foundation
import AVFoundation
import Alamofire

enum PlayerState {
    case play, pause
}

enum DownloadResult {
    case none, progress, complete(NSError?)
}

protocol DetailViewModelInterface {
    var avPlayer: Dynamic<AVPlayer?> {get set}
    var timePassed: Dynamic<(String, Float)> {get set}
    var durationStr: Dynamic<String> {get set}
    var loop: Dynamic<Loop> {get set}
    var state: Dynamic<PlayerState> {get set}
    var progress: Dynamic<Double> {get set}
    var downloadComplete: Dynamic<DownloadResult> {get set}
    var isOffline: Dynamic<Bool> {get set}
    var fileExist: Dynamic<Bool> {get set}
    var didDeleteFile: Dynamic<Bool> {get set}
    
    func process()
    func play()
    func pause()
    func download()
    func deleteFile()
    func loop(with type: Loop)
    func beginSliding()
    func endSliding(at value: Float)
    func checkFileExist()
}

class DetailViewModel: DetailViewModelInterface {
    var video: Video
    var avPlayer: Dynamic<AVPlayer?> = Dynamic<AVPlayer?>(nil)
    var timePassed: Dynamic<(String, Float)> = Dynamic<(String, Float)>(("0:0", 0.0))
    var durationStr: Dynamic<String> = Dynamic<String>("")
    var loop: Dynamic<Loop> = Dynamic<Loop>(.none)
    var state: Dynamic<PlayerState> = Dynamic<PlayerState>(.pause)
    var progress: Dynamic<Double> = Dynamic<Double>(0.0)
    var downloadComplete: Dynamic<DownloadResult> = Dynamic<DownloadResult>(.none)
    var isOffline: Dynamic<Bool> = Dynamic<Bool>(false)
    var fileExist: Dynamic<Bool> = Dynamic<Bool>(false)
    var didDeleteFile: Dynamic<Bool> = Dynamic<Bool>(false)
    
    private var duration: Float = 0.0
    private var timeObserver: Any?
    private var loopType = Loop.none
    private var loopCount = 0
    private var request: DownloadRequest?
    private var isDownloading = false
    
    init(video: Video) {
        self.video = video
    }
    
    func process() {
        self.checkNetworkOffline() ? processOffline() : processWhenReachableNetwork()
    }
    
    private func processOffline() {
        guard let urlString = video.localURL, let url = URL(string: urlString) else {
            return
        }
        let avPlayer = AVPlayer(url: url)
        self.avPlayer.value = avPlayer
        self.processDuration(avPlayer: avPlayer)
        self.addObserver()
        self.state.value = .play
        avPlayer.play()
    }
    
    private func processWhenReachableNetwork() {
        guard let urlStr = video.streamURL, let url =  URL(string: urlStr) else {
            return
        }
        let avPlayer = AVPlayer(url: url)
        self.avPlayer.value = avPlayer
        self.processDuration(avPlayer: avPlayer)
        self.addObserver()
        self.state.value = .play
        avPlayer.play()
    }
    
    private func processDuration(avPlayer: AVPlayer) {
        self.duration = Float(avPlayer.currentItem?.asset.duration.seconds ?? 0.0)
        self.durationStr.value = String.convertSeconds(from: duration)
    }
    
    private func addObserver() {
        let interval = CMTime(seconds: 0.05, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        self.timeObserver = self.avPlayer.value?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: {[weak self] (cmTime) in
            guard let strongSelf = self else { return }
            let time = Float(CMTimeGetSeconds(cmTime))
            strongSelf.timePassed.value = (String.convertSeconds(from: time), time / strongSelf.duration)
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.processWhenVideoDidPlayToEndTime(notification:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: self.avPlayer.value?.currentItem)
    }
    
    private func stopObserver() {
        self.avPlayer.value?.removeTimeObserver(self.timeObserver!)
        self.timeObserver = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    func play() {
        self.avPlayer.value?.play()
    }
    
    func pause() {
        self.avPlayer.value?.pause()
    }
    
    func loop(with type: Loop) {
        self.loopType = type
    }
    
    func beginSliding() {
        self.stopObserver()
    }
    
    func endSliding(at value: Float) {
        let targetTime = CMTime(seconds: Double(value * duration), preferredTimescale: 1)
        self.avPlayer.value?.seek(to: targetTime, completionHandler: {[weak self] (completed) in
            self?.addObserver()
            self?.avPlayer.value?.play()
            self?.state.value = .play
        })
    }
    
    func download() {
        guard !isDownloading else {
            return
        }
        self.isDownloading = true
        self.request = BaseNetwork.Detail.download(video: video, completionProgress: {[weak self] (percent) in
            self?.progress.value = percent
        }) {[weak self] (error, url) in
            self?.video.localURL = url?.path
            CoreDataStack.shared.saveContext()
            self?.downloadComplete.value = .complete(error)
            self?.isDownloading = false
        }
    }
    
    func deleteFile() {
        guard let path = self.video.localURL else {
            return
        }
        FileManager.default.deleteFile(at: path)
        self.didDeleteFile.value = true
    }
    
    func checkFileExist(){
        self.fileExist.value = self.video.isDownloaded
    }
    
    func checkNetworkOffline() -> Bool {
        self.isOffline.value = !Conectivity.isConnectedToInternet
        return self.isOffline.value
    }
    
    @objc func processWhenVideoDidPlayToEndTime(notification: Notification) {
        let avPlayerItem = notification.object as? AVPlayerItem
        self.state.value = .pause
        switch self.loopType {
        case .forever:
            self.loopCount = 0
            avPlayerItem?.seek(to: kCMTimeZero, completionHandler: { (completed) in
                self.avPlayer.value?.play()
            })
            break
        case .one:
            guard loopCount == 0 else {
                self.loopCount = 0
                self.loop.value = .none
                return
            }
            loopCount += 1
            avPlayerItem?.seek(to: kCMTimeZero, completionHandler: {[weak self] (completed) in
                self?.avPlayer.value?.play()
            })
            break
        default:
            self.loopCount = 0
            break
        }
    }
    
    deinit {
        self.stopObserver()
        self.avPlayer.value?.pause()
        self.request?.cancel()
    }
}


