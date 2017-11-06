//
//  Ext+FileManager.swift
//  StreamingVideo
//
//  Created by huydoquang on 11/6/17.
//  Copyright © 2017 huydoquang. All rights reserved.
//

import Foundation

extension FileManager {
    func createDefaultLocalURL(with downloadURL: URL, fileName: String) -> URL {
        let lastPathComponent = downloadURL.lastPathComponent as NSString
        let pathExtension = lastPathComponent.pathExtension
        var documentsURL = self.urls(for: .documentDirectory, in: .userDomainMask)[0]
        documentsURL.appendPathComponent(fileName + "." + pathExtension)
        return documentsURL
    }
    
    func deleteFile(at path: String) {
        guard self.fileExists(atPath: path) else {
            return
        }
        do {
            try self.removeItem(atPath: path)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}
