//
//  UsepermissionController.swift
//  Move App
//
//  Created by LX on 2017/3/4.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import CustomViews
import RxSwift
import RxCocoa
import RxOptional

class UsepermissionController: UITableViewController {

    @IBOutlet weak var myfriendQulet: SwitchButton!
    @IBOutlet weak var calltofriendQulet: SwitchButton!
    @IBOutlet weak var groupchatQulet: SwitchButton!
    @IBOutlet weak var voicechagerQulet: SwitchButton!
    @IBOutlet weak var playinghamsterQulet: SwitchButton!
    
    @IBOutlet weak var saveQulet: UIBarButtonItem!
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel = UsepermissionViewModel(
            input: (
                btn0: myfriendQulet.rx.value.asDriver(),
                btn1: calltofriendQulet.rx.value.asDriver(),
                btn2: groupchatQulet.rx.value.asDriver(),
                btn3: voicechagerQulet.rx.value.asDriver(),
                btn4: playinghamsterQulet.rx.value.asDriver()
            ),
            dependency: (
                settingsManager: WatchSettingsManager.share,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance,
                disposeBag: disposeBag
            )
        )
        
        viewModel.selected0Variable.asDriver().drive(myfriendQulet.rx.value).addDisposableTo(disposeBag)
        viewModel.selected1Variable.asDriver().drive(calltofriendQulet.rx.value).addDisposableTo(disposeBag)
        viewModel.selected2Variable.asDriver().drive(groupchatQulet.rx.value).addDisposableTo(disposeBag)
        viewModel.selected3Variable.asDriver().drive(voicechagerQulet.rx.value).addDisposableTo(disposeBag)
        viewModel.selected4Variable.asDriver().drive(playinghamsterQulet.rx.value).addDisposableTo(disposeBag)
        
      //网络请求的时候都不用点击
        viewModel.activityIn
            .map { !$0 }
            .drive(onNext: userInteractionEnabled)
            .addDisposableTo(disposeBag)
    }
    
    func userInteractionEnabled(enable: Bool) {
        myfriendQulet.isEnabled = enable
        calltofriendQulet.isEnabled = enable
        groupchatQulet.isEnabled = enable
        voicechagerQulet.isEnabled = enable
        playinghamsterQulet.isUserInteractionEnabled = enable
        saveQulet.isEnabled = enable
    }

    
}
