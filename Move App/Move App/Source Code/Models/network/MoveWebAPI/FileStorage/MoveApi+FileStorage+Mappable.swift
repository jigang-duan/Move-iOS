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
        var file: Data?
    }
    
    struct FileId {
        var fid: String?
    }
    
}

extension MoveApi.FileInfo: Mappable {
    init?(map: Map) {
    }
    
    init(file: Data) {
        self.file = file
    }
    
    mutating func mapping(map: Map) {
        type <- map["type"]
        duration <- map["duration"]
        file <- map["file"]
    }
}

extension MoveApi.FileId: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        fid <- map["fid"]
    }
}

