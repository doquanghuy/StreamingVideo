//
//  Video+CoreDataProperties.swift
//  StreamingVideo
//
//  Created by huydoquang on 10/31/17.
//  Copyright © 2017 huydoquang. All rights reserved.
//
//

import Foundation
import CoreData


extension Video {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Video> {
        return NSFetchRequest<Video>(entityName: "Video")
    }

    @NSManaged public var offlineURL: String?
    @NSManaged public var backgroundImageURL: String?
    @NSManaged public var name: String?
    @NSManaged public var id: Int32
    @NSManaged public var streamURL: String?
    @NSManaged public var localURL: String?
}
