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
        let id =  json["id"].int32!
        let manageObjContext = CoreDataStack.shared.managedContext
        let video = self.video(with: id) ?? Video(context: manageObjContext)
        
        if let backgroundImageURL =  json["background_image_url"].string {
            video.backgroundImageURL = backgroundImageURL
        }
        video.id = id
        if let streamURL = json["stream_url"].string {
            video.streamURL = streamURL
        }
        if let offlineURL = json["offline_url"].string {
            video.offlineURL = offlineURL
        }
        if let name = json["name"].string {
            video.name = name
        }
        return video
    }
    
    static func createOrUpdateMultiVideo(with json: JSON, context: NSManagedObjectContext? = nil) -> [Video] {
        let manageObjContext = CoreDataStack.shared.managedContext
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
    
    static func video(with id: Int32) -> Video? {
        let fetchRequest: NSFetchRequest<Video> = Video.fetchRequest()
        let predicateID = NSPredicate(format: "id == %@", String(id))
        fetchRequest.predicate = predicateID
        return (try? CoreDataStack.shared.managedContext.fetch(fetchRequest).first) as? Video
    }
}
