//
//  MoveApi+FileStorage+Mappable.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/2/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import ObjectMapper


extension MoveApi {
    
    struct FileInfo {
        var type: String?
        var duration: Int?
        var data: Data?
    }
    
    struct FileUploadResp {
        var fid: String?
        var progress: Double?
    }
    
    struct FileStorageInfo {
        var name: String?
        var type: String?
        var path: URL?
        var fid: String?
        var progress: Double?
        var progressObject: Progress?
    }
    
}

extension MoveApi.FileInfo: Mappable {
    init?(map: Map) {
    }
    
    init(data: Data) {
        self.data = data
    }
    
    mutating func mapping(map: Map) {
        type <- map["type"]
        duration <- map["duration"]
        data <- map["file"]
    }
}

extension MoveApi.FileUploadResp: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        fid <- map["fid"]
    }
}

extension MoveApi.FileStorageInfo: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        
    }
}
