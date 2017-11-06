//
//  Video+CoreDataClass.swift
//  StreamingVideo
//
//  Created by huydoquang on 10/31/17.
//  Copyright © 2017 huydoquang. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON

public class Video: NSManagedObject {
    var isDownloaded: Bool {
        return self.localURL != nil
    }
    
    static func createOrUpdateVideo(with json: JSON, context: NSManagedObjectContext? = nil) -> Video {
        let manageObjContext = context ?? (UIApplication.shared.delegate as? AppDelegate)!.coreDataStack.managedContext
        let newVideo = Video(context: manageObjContext)
        newVideo.backgroundImageURL = json["background_image_url"].string
        newVideo.id = json["id"].int32!
        newVideo.streamURL = json["stream_url"].string
        newVideo.offlineURL = json["offline_url"].string
        newVideo.name = json["name"].string
        return newVideo
    }
    
    static func createOrUpdateMultiVideo(with json: JSON, context: NSManagedObjectContext? = nil) -> [Video] {
        let manageObjContext = context ?? (UIApplication.shared.delegate as? AppDelegate)!.coreDataStack.managedContext
        var videos = [Video]()
        for json in json.arrayValue {
            let video = self.createOrUpdateVideo(with: json, context: manageObjContext)
            videos.append(video)
        }
        do {
            try context?.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return videos
    }
}
