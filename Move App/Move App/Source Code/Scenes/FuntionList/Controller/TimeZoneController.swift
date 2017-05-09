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
    
    var selectedTimeZone = Variable(0)
    
    var disposeBag = DisposeBag()
    
    func internationalization() {
        timezoneTitleItem.title = R.string.localizable.id_time_zone()
        hoursFormatLabel.text = R.string.localizable.id_hours_format24()
        gettimeautoLabel.text = R.string.localizable.id_get_time_auto()
        timezoneLabel.text = R.string.localizable.id_time_zone()
        summerTimeLabel.text = R.string.localizable.id_summer_time()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.internationalization()
        
        selectedTimeZone.asDriver()
            .map({ "GMT \($0)" })
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


