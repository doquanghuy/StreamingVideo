//
//  BaseNetwork.swift
//  StreamingVideo
//
//  Created by huydoquang on 10/30/17.
//  Copyright © 2017 huydoquang. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct BaseNetwork {
    static func request(method: HTTPMethod = .get, url: URL, header: [String: String]? = nil,  parameters: [String: Any]? = nil, encoding: ParameterEncoding = JSONEncoding.default, completion: ((_ error: Error?, _ json: JSON?) -> Void)? = nil) -> DataRequest? {
        return Alamofire.request(url, method: method, parameters: nil, encoding: encoding, headers: header)
            .validate()
            .responseJSON { (response) in
                if let error = response.error {
                    completion?(error, nil)
                    return
                }
                if let jsonData = response.result.value {
                    completion?(nil, JSON(jsonData))
                    return
                }
                completion?(nil, nil)
        }
    }
    
    static func downloadAudioFromURL(urlString: String, fileName: String, completionProgress: ((Double) -> Void)? = nil, completion: ((_ error: NSError?, _ audioLocalURL: URL?) -> Void)? = nil) -> DownloadRequest? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.createDefaultLocalURL(with: url, fileName: fileName)
            return (documentsURL, [.removePreviousFile])
        }
        
        return Alamofire.download(url, to: destination)
            .downloadProgress(closure: { (progress) in
                let percent = progress.fractionCompleted
                completionProgress?(percent)
            })
            .response { response in
            if let error = response.error as NSError? {
                completion?(error, nil)
                return
            }
            completion?(nil, response.destinationURL)
        }
    }
}
