//
//  Ext+String.swift
//  StreamingVideo
//
//  Created by huydoquang on 11/6/17.
//  Copyright © 2017 huydoquang. All rights reserved.
//

import Foundation

extension String {
    static func convertSeconds(from time: Float) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
}
