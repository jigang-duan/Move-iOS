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
    let selected0Variable = Variable(false)
    let selected1Variable = Variable(false)
    let selected2Variable = Variable(false)
    let selected3Variable = Variable(false)
    let selected4Variable = Variable(false)
    let activityIn: Driver<Bool>
    
    // }
    
    init(
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
            .shareReplay(1)
            .trackActivity(activitying)
            .asDriver(onErrorJustReturn: [false,false,false,false,false])
            .filter({ $0.count>=5 })
        fetchPermissions.map({$0[0]}).drive(selected0Variable).addDisposableTo(disposeBag)
        fetchPermissions.map({$0[1]}).drive(selected1Variable).addDisposableTo(disposeBag)
        fetchPermissions.map({$0[2]}).drive(selected2Variable).addDisposableTo(disposeBag)
        fetchPermissions.map({$0[3]}).drive(selected3Variable).addDisposableTo(disposeBag)
        fetchPermissions.map({$0[4]}).drive(selected4Variable).addDisposableTo(disposeBag)
        
        //问题：延迟一个按钮上传数据
        let selectPermission = Observable.combineLatest(selected0Variable.asObservable(),
                                                    selected1Variable.asObservable(),
                                                    selected2Variable.asObservable(),
                                                    selected3Variable.asObservable(),
                                                    selected4Variable.asObservable()) { [$0, $1, $2, $3, $4] }
        selectPermission
            .skip(1)
            .flatMapLatest { selectBtns in
                manager.upUsePermission(selectBtns)
                    .trackActivity(activitying)
                    .asDriver(onErrorJustReturn: false)
            }
            .bindNext({_ in})
            .addDisposableTo(disposeBag)
    }

}
