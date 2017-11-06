//
//  Constants.swift
//  StreamingVideo
//
//  Created by huydoquang on 10/30/17.
//  Copyright © 2017 huydoquang. All rights reserved.
//

import Foundation

struct Constants {
    struct String {
        static let downloadComplete = "Download complete"
        static let unableOpenDetailTitle = "Can not open video"
        static let cancelButton = "Cancel"
        static let okButton = "OK"
        static let deleteTitle = "Do you want delete this video?"
    }
    
    struct Image {
        static let play = "ic-play"
        static let pause = "ic-pause"
        static let unloop = "ic-unloop"
        static let loopForever = "ic-loop-forever"
        static let loopOne = "ic-loop-one"
    }
    
    struct Segue {
        static let showDetailVideoViewController = "showDetailVideoViewController"
    }
    
    struct KeyPath {
        static let avPlayerStatus = "status"
    }
}
