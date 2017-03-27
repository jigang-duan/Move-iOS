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
    //internationalization
    @IBOutlet weak var usepermissonTitleItem: UINavigationItem!
    @IBOutlet weak var myfriendLabel: UILabel!
    @IBOutlet weak var calltofriendLabel: UILabel!
    @IBOutlet weak var groupchatLabel: UILabel!
    @IBOutlet weak var voicechangeLabel: UILabel!
    @IBOutlet weak var playingHamsteLabel: UILabel!
    
    
    @IBOutlet weak var myfriendQulet: SwitchButton!
    @IBOutlet weak var groupchatQulet: SwitchButton!
    @IBOutlet weak var voicechagerQulet: SwitchButton!
    @IBOutlet weak var playinghamsterQulet: SwitchButton!
    
    @IBOutlet weak var saveQulet: UIBarButtonItem!
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel = UsepermissionViewModel(
            dependency: (
                settingsManager: WatchSettingsManager.share,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance,
                disposeBag: disposeBag
            )
        )
        
        (myfriendQulet.rx.value <-> viewModel.selected0Variable).addDisposableTo(disposeBag)
      //  (calltofriendQulet.rx.value <-> viewModel.selected1Variable).addDisposableTo(disposeBag)
        (groupchatQulet.rx.value <-> viewModel.selected1Variable).addDisposableTo(disposeBag)
        (voicechagerQulet.rx.value <-> viewModel.selected2Variable).addDisposableTo(disposeBag)
        (playinghamsterQulet.rx.value <-> viewModel.selected3Variable).addDisposableTo(disposeBag)
        
      //网络请求的时候都不用点击
        viewModel.activityIn
            .map { !$0 }
            .drive(onNext: userInteractionEnabled)
            .addDisposableTo(disposeBag)
    }
    
    func userInteractionEnabled(enable: Bool) {
//        myfriendQulet.isEnabled = enable
//        calltofriendQulet.isEnabled = enable
//        groupchatQulet.isEnabled = enable
//        voicechagerQulet.isEnabled = enable
//        playinghamsterQulet.isUserInteractionEnabled = enable
//        saveQulet.isEnabled = enable
    }

    
}
