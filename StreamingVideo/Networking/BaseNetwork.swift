//
//  BaseNetwork.swift
//  StreamingVideo
//
//  Created by huydoquang on 10/30/17.
//  Copyright © 2017 huydoquang. All rights reserved.
//

import Foundation
import Alamofire

enum RequestMethod {
    case get, post, put
}

struct BaseNetwork {
    static func request(method: RequestMethod, url: URL, completion: ((_ error: NSError?, _ json: j))? = nil)
}
