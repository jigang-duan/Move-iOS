//
//  LocationEntity.swift
//  Move App
//
//  Created by lx on 17/2/22.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Realm
import RealmSwift
 //LBS定位
class LBSList: Object {
    dynamic var device_id : String? = nil
    dynamic var imei : String? = nil
    var location = List<LBSLocationEntity>()
}

class LBSLocationEntity: Object {
    dynamic var lat : Double = 0.000000
    dynamic var lng : Double = 0.000000
    dynamic var addr: String? = nil
    dynamic var accuracy: Int = 0
    dynamic var time: Int64 = 0
}
//获取批量步数
class StepsList: Object {
    var steps = List<LBSLocationEntity>()
}

class StepsEntity: Object {
    dynamic var uid: String? = nil
    dynamic var step : Int64 = 0
    dynamic var distance: Int64 = 0
    dynamic var calorie: Int = 0
    dynamic var like_count: Int = 0
    dynamic var liked: Bool = false
}

//获取单个步数
class SingeStepsList: Object {
    var steps = List<SingeStepsEntity>()
}

class SingeStepsEntity: Object {
    dynamic var uid: String? = nil
    dynamic var step : Int64 = 0
    dynamic var distance: Int64 = 0
    dynamic var calorie: Int = 0
    dynamic var time: Int64 = 0
}
