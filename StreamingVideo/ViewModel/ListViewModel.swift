//
//  ListViewModel.swift
//  StreamingVideo
//
//  Created by huydoquang on 10/30/17.
//  Copyright © 2017 huydoquang. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

enum FetchListVideoResult {
    case begin
    case error(Error?)
    case success
}

protocol ListViewModelInterface: class{
    var result: Dynamic<FetchListVideoResult> {get set}
    func fetchListVideos()
    func cancelRequest()
}

protocol ListViewModelProvider: class {
    func numberOfRow(in section: Int) -> Int
    func video(at indexPath: IndexPath) -> Video
}

class ListViewModel {
    var result = Dynamic<FetchListVideoResult>(.begin)
    var videos = [Video]()
    var request: DataRequest?
}

extension ListViewModel: ListViewModelInterface {
    func fetchListVideos() {
        Conectivity.isConnectedToInternet ? fetchVideoReachableNetwork() : fetchVideoOffline()
    }
    
    private func fetchVideoOffline() {
        let fetchRequest: NSFetchRequest<Video> = Video.fetchRequest()
        self.videos = (try? CoreDataStack.shared.managedContext.fetch(fetchRequest)) ?? []
        self.result.value = !self.videos.isEmpty ? .success : .error(nil)
    }
    
    private func fetchVideoReachableNetwork() {
        guard let url = URL(string: Configuration.List.url) else {
            return
        }
        self.request = BaseNetwork.List.getListVideos(url: url) { (error, json) in
            if let error = error {
                self.result.value = .error(error)
                return
            }
            guard let json = json else {
                self.result.value = .error(nil)
                return
            }
            self.videos = Video.createOrUpdateMultiVideo(with: json)
            self.result.value = .success
        }
    }
    
    func cancelRequest() {
        self.request?.cancel()
    }
}

extension ListViewModel: ListViewModelProvider {
    func numberOfRow(in section: Int) -> Int {
        return self.videos.count
    }
    
    func video(at indexPath: IndexPath) -> Video {
        return self.videos[indexPath.row]
    }
}
