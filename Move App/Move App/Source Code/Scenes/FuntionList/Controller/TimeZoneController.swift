//
//  TimeZoneController.swift
//  Move App
//
//  Created by LX on 2017/3/6.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import CustomViews
import RxSwift
import RxCocoa
import RxOptional

class TimeZoneController: UITableViewController {
    //internationalization
    @IBOutlet weak var timezoneTitleItem: UINavigationItem!
    @IBOutlet weak var hoursFormatLabel: UILabel!
    @IBOutlet weak var gettimeautoLabel: UILabel!
    @IBOutlet weak var timezoneLabel: UILabel!
    @IBOutlet weak var summerTimeLabel: UILabel!
    
    
    @IBOutlet weak var hourFormatQutlet: SwitchButton!
    @IBOutlet weak var autoGetTimeQutlet: SwitchButton!
    @IBOutlet weak var summerTimeQutlet: SwitchButton!
    @IBOutlet weak var timezoneCityQutlet: UILabel!
    
    @IBOutlet weak var timezoneCell: UITableViewCell!
    
    @IBOutlet weak var backQutlet: UIBarButtonItem!
    //var selectTimeZoneController: SelectTimeZoneController?
    
    var selectedTimeZone = Variable("")
    
    var disposeBag = DisposeBag()
    
    func internationalization() {
        timezoneTitleItem.title = R.string.localizable.id_time_zone()
        hoursFormatLabel.text = R.string.localizable.id_hours_format24()
        gettimeautoLabel.text = R.string.localizable.id_get_time_auto()
        timezoneLabel.text = R.string.localizable.id_time_zone()
        summerTimeLabel.text = R.string.localizable.id_summer_time()
    }
    func enablecell(_ enable: Bool) {
        timezoneCell.isUserInteractionEnabled = !enable
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.internationalization()
        
        //auto on timecell off ,off on 控制跳转
        let openEnable = autoGetTimeQutlet.rx.switch.asDriver()
        openEnable.drive(onNext: enablecell).addDisposableTo(disposeBag)
        
        selectedTimeZone.asDriver()
            .map({ " \($0)" })//不知道为什么赋不上值，非要转一下加点东西
            .drive(timezoneCityQutlet.rx.text)
            .addDisposableTo(disposeBag)
        
        let viewModel = TimeZoneViewModel(
            input: (
                hourform: hourFormatQutlet.rx.value.asDriver(),
                autotime: autoGetTimeQutlet.rx.value.asDriver(),
                timezone: selectedTimeZone.asDriver(),
                summertime: summerTimeQutlet.rx.value.asDriver()
            ),
            dependency: (
                settingsManager: WatchSettingsManager.share,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        viewModel.saveFinish
            .drive(onNext: {_ in
            }).addDisposableTo(disposeBag)

        viewModel.hourformEnable.drive(hourFormatQutlet.rx.on).addDisposableTo(disposeBag)
        viewModel.autotimeEnable.drive(autoGetTimeQutlet.rx.on).addDisposableTo(disposeBag)
        viewModel.fetchtimezoneDate.drive(selectedTimeZone).addDisposableTo(disposeBag)
        viewModel.summertimeEnable.drive(summerTimeQutlet.rx.on).addDisposableTo(disposeBag)
        viewModel.autotimeEnable.drive(onNext: enablecell).addDisposableTo(disposeBag)
        viewModel.activityIn
            .map{ !$0 }
            .drive(onNext: userInteractionEnabled)
            .addDisposableTo(disposeBag)


    }
    
    func userInteractionEnabled(enable: Bool) {
       // hourFormatQutlet.isEnabled = enable
      //  autoGetTimeQutlet.isEnabled = enable
      //  summerTimeQutlet.isEnabled = enable
      //  backQutlet.isEnabled = enable
      //  timezoneCell.isUserInteractionEnabled = enable
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = R.segue.timeZoneController.showSelectTimeZone(segue: segue)?.destination {
            vc.selectedTimezone = { index in
                self.selectedTimeZone.value = index
            }
        }
    }


}


