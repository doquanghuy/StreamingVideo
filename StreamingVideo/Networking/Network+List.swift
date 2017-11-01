//
//  Network+List.swift
//  StreamingVideo
//
//  Created by huydoquang on 10/30/17.
//  Copyright © 2017 huydoquang. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension BaseNetwork {
    struct List {
        static func getListVideos(url: URL, completion: ((_ error: Error?, _ json: JSON?) -> Void)? = nil) -> DataRequest? {
            return BaseNetwork.request(url: url, completion: completion)
        }
    }
}
