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
}
