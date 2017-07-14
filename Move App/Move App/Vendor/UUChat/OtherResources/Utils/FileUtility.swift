//
//  FileUtility.swift
//  kidwatchapp
//
//  Created by zhengying on 9/24/15.
//  Copyright © 2015 zhengying. All rights reserved.
//

import Foundation

class FileUtility {
    class func documentURL() -> URL? {
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
    
        // If array of path is empty the document folder not found
        guard urls.count == 0 else {
            print(urls.first!)
            return urls.first!
        }
        
        return nil
    }
    
    class func libraryCachesURL() -> URL? {
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        
        // If array of path is empty the document folder not found
        guard urls.count == 0 else {
            print(urls.first!)
            return urls.first!
        }
        
        return nil
    }
    
    class func rename(fileURL: URL, name: String) -> URL? {
        let fileManager = FileManager.default
        guard fileURL.isFileURL, fileManager.fileExists(atPath: fileURL.path) else { return nil }
        let to = fileURL.deletingLastPathComponent().appendingPathComponent(name)
        try? fileManager.copyItem(at: fileURL, to: to)
        return to
    }
}


struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}
