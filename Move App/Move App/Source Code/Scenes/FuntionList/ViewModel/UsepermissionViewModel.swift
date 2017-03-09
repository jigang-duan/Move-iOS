//
//  UsepermissionViewModel.swift
//  Move App
//
//  Created by LX on 2017/3/4.
//  Copyright © 2017年 TCL Com. All rights reserved.
//


import Foundation
import RxSwift
import RxCocoa

class UsepermissionViewModel {
    // outputs {
    
    //
    //let selectBtns: Driver<[Bool]>
    let selected0Variable = Variable(false)
    let selected1Variable = Variable(false)
    let selected2Variable = Variable(false)
    let selected3Variable = Variable(false)
    let selected4Variable = Variable(false)
    //let saveFinish: Driver<Bool>
    
    
    let activityIn: Driver<Bool>
    
    // }
    
    init(
        input: (
        btn0: Driver<Bool>,
        btn1: Driver<Bool>,
        btn2: Driver<Bool>,
        btn3: Driver<Bool>,
        btn4: Driver<Bool>
        ),
        dependency: (
        settingsManager: WatchSettingsManager,
        validation: DefaultValidation,
        wireframe: Wireframe,
        disposeBag: DisposeBag
        )
        ) {
        
        let manager = dependency.settingsManager
        let disposeBag = dependency.disposeBag
        
        let activitying = ActivityIndicator()
        self.activityIn = activitying.asDriver()
 
        let fetchPermissions =  manager.fetchUsePermission()
            .trackActivity(activitying)
            .asDriver(onErrorJustReturn: [])
        fetchPermissions.map({$0[0]}).drive(selected0Variable).addDisposableTo(disposeBag)
        fetchPermissions.map({$0[1]}).drive(selected1Variable).addDisposableTo(disposeBag)
        fetchPermissions.map({$0[2]}).drive(selected2Variable).addDisposableTo(disposeBag)
        fetchPermissions.map({$0[3]}).drive(selected3Variable).addDisposableTo(disposeBag)
        fetchPermissions.map({$0[4]}).drive(selected4Variable).addDisposableTo(disposeBag)
        
        input.btn0.drive(selected0Variable).addDisposableTo(disposeBag)
        input.btn1.drive(selected1Variable).addDisposableTo(disposeBag)
        input.btn2.drive(selected2Variable).addDisposableTo(disposeBag)
        input.btn3.drive(selected3Variable).addDisposableTo(disposeBag)
        input.btn4.drive(selected4Variable).addDisposableTo(disposeBag)
        //问题：延迟一个按钮上传数据
        let selectPermission = Driver.combineLatest(selected0Variable.asDriver(),
                                                    selected1Variable.asDriver(),
                                                    selected2Variable.asDriver(),
                                                    selected3Variable.asDriver(),
                                                    selected4Variable.asDriver()) { [$0, $1, $2, $3, $4] }
        //self.saveFinish =
        Driver.of(input.btn0, input.btn1, input.btn2, input.btn3, input.btn4).merge()
            .withLatestFrom(selectPermission)
            .flatMapLatest { selectBtns in
                manager.upUsePermission(selectBtns)
                    .trackActivity(activitying)
                    .asDriver(onErrorJustReturn: false)
            }
            .drive(onNext: {_ in})
            .addDisposableTo(disposeBag)
    }

}
