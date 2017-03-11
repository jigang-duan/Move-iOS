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
    let languageVariable = Variable("en")
    let lauguage: Driver<String>
    let lauguages: Driver<[String]>
    
    let activityIn: Driver<Bool>
    
    let saveFinish: Driver<Bool>
    // }
    
    init(
        input: (
        selectedlanguage: Driver<String>,
        empty: Void
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
        
        self.lauguage = manager.fetchLanguage()
            .trackActivity(activitying)
            .asDriver(onErrorJustReturn: "")
        
        self.saveFinish = input.selectedlanguage
            .flatMapFirst { language in
                manager.updateLanguage(language)
                    .trackActivity(activitying)
                    .asDriver(onErrorJustReturn: false)
        }
    }
    
}
