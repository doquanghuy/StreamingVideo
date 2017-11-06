//
//  Conectivity.swift
//  StreamingVideo
//
//  Created by huydoquang on 11/6/17.
//  Copyright © 2017 huydoquang. All rights reserved.
//

import Foundation
import Alamofire

struct Conectivity {
    static let sharedInstance = NetworkReachabilityManager()!
    
    static var isConnectedToInternet:Bool {
        return self.sharedInstance.isReachable
    }
}
