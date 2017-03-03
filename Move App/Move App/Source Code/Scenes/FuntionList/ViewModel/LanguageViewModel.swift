//
//  LanguageViewModel.swift
//  Move App
//
//  Created by xiaohui on 17/3/1.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class LanguageViewModel {
    // outputs {
    
    //
    let language: Driver<String>
    let lauguages: Driver<[String]>
    
    let activityIn: Driver<Bool>
    
    let saveFinish: Driver<Bool>
    // }
    
    init(
        input: (
        language: Driver<String>,
        save: Driver<Void>
        ),
        dependency: (
        settingsManager: WatchSettingsManager,
        validation: DefaultValidation,
        wireframe: Wireframe
        )
        ) {
        
        let manager = dependency.settingsManager
        
        let activitying = ActivityIndicator()
        self.activityIn = activitying.asDriver()
        
        self.lauguages = manager.fetchLanguages()
            .trackActivity(activitying)
            .asDriver(onErrorJustReturn: [])
        
        self.language = manager.fetchLanguage()
            .trackActivity(activitying)
            .asDriver(onErrorJustReturn: "")
        
        self.saveFinish = input.save.withLatestFrom(language)
            .flatMapFirst { language in
                manager.updateLanguage(language)
                    .trackActivity(activitying)
                    .asDriver(onErrorJustReturn: false)
        }
    }
    
}
