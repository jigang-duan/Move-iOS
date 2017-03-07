//
//  MoveApi+ActivityRecord+Mappable.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/2/13.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import ObjectMapper


extension MoveApi {
    
    enum ActivityActionType: String {
        case walk = "WALK"
        case run = "RUN"
        case hamster = "HAMSTER"
    }
    
    struct Activity {
        var id: String?
        var start_time: Date?
        var end_time: Date?
        var action_type: ActivityActionType?
        var total_distance: Double?
        var total_calories: Int?
        var total_duration: Int?
        var total_steps: Int?
        var total_score: Int?
        var new_page_token: String?
    }
    
    struct ActivityList {
        var activitys: [Activity]?
    }
    
    struct RecordReq {
        var start_time: Date?
        var end_time: Date?
        var page_token: String?
        var page_size: Int?
    }
    
    struct Contact {
        var uid: String?
    }

    struct StepList {
        var steps: [Step]?
    }
    
    struct Step{
        var uid: String?
        var step: Int64?
        var distance: Int?
        var calorie: Int?
        var time: Date?
        var like_count: Int?
        var liked: Bool?
    }
    
    struct StepSumReq {
        var start_time: Date?
        var end_time: Date?
        var by: String?
    }
    
    struct RecordScoreList {
        var scores: [RecordScore]?
    }
    
    struct RecordScore {
        var uid: String?
        var score: Int?
        var like_count: Int?
        var liked: Bool?
    }
}


extension MoveApi.Activity: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        start_time <- (map["start_time"], DateIntTransform())
        end_time <- (map["end_time"], DateIntTransform())
        action_type <- map["action_type"]
        total_distance <- map["total_distance"]
        total_calories <- map["total_calories"]
        total_duration <- map["total_duration"]
        total_steps <- map["total_steps"]
        total_score <- map["total_score"]
        new_page_token <- map["new_page_token"]
    }
}

extension MoveApi.ActivityList: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        activitys <- map["activity"]
    }
}

extension MoveApi.RecordReq: Mappable {
    init?(map: Map) {
    }
    
    init(start_time: Date, end_time: Date) {
        self.start_time = start_time
        self.end_time = end_time
    }
    
    mutating func mapping(map: Map) {
        start_time <- (map["start_time"], DateIntTransform())
        end_time <- (map["end_time"], DateIntTransform())
        page_token <- map["page_token"]
        page_size <- map["page_size"]
    }
}

extension MoveApi.Contact: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        uid <- map["uid"]
    }
}

extension MoveApi.StepList: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        steps <- map["steps"]
    }
}


extension MoveApi.Step: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        uid <- map["uid"]
        step <- map["step"]
        distance <- map["distance"]
        calorie <- map["calorie"]
        time <- (map["time"], DateIntTransform())
        like_count <- map["like_count"]
        liked <- map["liked"]
    }
}

extension MoveApi.StepSumReq: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        start_time <- (map["start_time"], DateIntTransform())
        end_time <- (map["end_time"], DateIntTransform())
        by <- map["by"]
    }
}

extension MoveApi.RecordScoreList: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        scores <- map["scores"]
    }
}


extension MoveApi.RecordScore: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        uid <- map["uid"]
        score <- map["score"]
        like_count <- map["like_count"]
        liked <- map["liked"]
    }
}




