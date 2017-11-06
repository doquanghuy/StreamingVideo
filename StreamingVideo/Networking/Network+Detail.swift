//
//  Network+Detail.swift
//  StreamingVideo
//
//  Created by huydoquang on 11/6/17.
//  Copyright © 2017 huydoquang. All rights reserved.
//

import UIKit
import Alamofire

extension BaseNetwork {
    struct Detail {
        static func download(video: Video, completionProgress: ((Double) -> Void)? = nil, completion: ((_ error: NSError?, _ destinationURL: URL?) -> Void)? = nil) -> DownloadRequest? {
            guard let fileName = video.name, let urlString = video.offlineURL else {
                completion?(nil, nil)
                return nil
            }
            return BaseNetwork.downloadAudioFromURL(urlString: urlString, fileName: fileName, completionProgress: { (percent) in
                completionProgress?(percent)
            }) { (error, url) in
                completion?(error, url)
            }
        }
    }
}
