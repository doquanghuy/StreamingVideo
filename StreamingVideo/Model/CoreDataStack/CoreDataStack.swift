//
//  CoreDataStack.swift
//  StreamingVideo
//
//  Created by huydoquang on 10/31/17.
//  Copyright © 2017 huydoquang. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    private let modelName: String
    private let storeName: String = "StreamingVideo"
    static let shared = CoreDataStack(modelName: "StreamingVideo")
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.persistentStoreDescriptions = [self.storeDescription]
        container.loadPersistentStores {(storeDesciption, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
            
        }
        return container
    }()
    
    lazy var managedContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    var storeURL : URL {
        let storePaths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let storePath = storePaths[0] as NSString
        let fileManager = FileManager.default
        
        do {
            try fileManager.createDirectory(
                atPath: storePath as String,
                withIntermediateDirectories: true,
                attributes: nil)
        } catch {
            print("Error creating storePath \(storePath): \(error)")
        }
        
        let sqliteFilePath = storePath
            .appendingPathComponent(storeName + ".sqlite")
        return URL(fileURLWithPath: sqliteFilePath)
    }
    
    lazy var storeDescription: NSPersistentStoreDescription = {
        let description = NSPersistentStoreDescription(url: self.storeURL)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = false
        return description
    }()
    
    func saveContext() {
        guard managedContext.hasChanges else {return}
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
}

