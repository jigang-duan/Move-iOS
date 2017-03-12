////
////  RemindersViewModel.swift
////  Move App
////
////  Created by LX on 2017/3/12.
////  Copyright © 2017年 TCL Com. All rights reserved.
////
//
//import Foundation
//import RxSwift
//import RxCocoa
//import RxOptional
//
//class RemindersViewModel {
//    // outputs {
//    
//    let alarmsVariable = Variable(["alarms":DateUtility.zone7hour(),"dayFromWeekVariable":[false, false, false, false, false, false, false],"activeVariable":false])
//    
////    let alarm = Variable(DateUtility.zone7hour())
////    let dayFromWeekVariable = Variable([false, false, false, false, false, false, false])
////    let activeVariable = Variable(false)
//    
//    let todoVariable = Variable(["topic":"Do homewirk","content":"Remember to finished","start":DateUtility.zone14hour(),"end":DateUtility.zone16hour(),"repeatcount":1])
//    
////    let topic = Variable("Do homewirk")
////    let content = Variable("Remember to finished")
////    let start = Variable(DateUtility.zone14hour())
////    let end = Variable(DateUtility.zone16hour())
////    let repeatcount = Variable(1)
//    let delectFinish: Driver<Bool>
//    let activityIn: Driver<Bool>
//    
//    // }
//    
//    init(
//        input: (
//        deldect: Driver<Void>,
//        empty: Void
//        ),
//        dependency: (
//        kidSettingsManager: KidSettingsManager,
//        validation: DefaultValidation,
//        wireframe: Wireframe,
//        disposeBag: DisposeBag
//        )
//        ) {
//        
//        let manager = dependency.kidSettingsManager
//        let disposeBag = dependency.disposeBag
//        
//        let activitying = ActivityIndicator()
//        self.activityIn = activitying.asDriver()
//        
//        //网络拉下来的数据
//        let reminderInfomation = manager.fetchreminder()
//            .trackActivity(activitying)
//             .shareReplay(1)
//        
//        reminderInfomation.map({ $0.alarms }).dr
//        
//        
//     
//        
//        
//
//    }
//
//    
//    
//}
