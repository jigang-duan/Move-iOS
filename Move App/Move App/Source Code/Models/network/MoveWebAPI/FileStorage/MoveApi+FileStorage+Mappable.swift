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
        var fileName: String?
        var mimeType: String?
    }
    
    struct FileUploadResp {
        var fid: String?
        var progress: Double?
    }
    
    struct FileStorageInfo {
        var name: String?
        var mimeType: String?
        var path: URL?
        var fid: String?
    }
    
}

extension MoveApi.FileUploadResp: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        fid <- map["fid"]
    }
}

