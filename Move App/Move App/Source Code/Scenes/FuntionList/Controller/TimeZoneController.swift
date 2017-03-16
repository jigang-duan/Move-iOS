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
    
    var selectedTimeZone = Variable(TimeZone.current)
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedTimeZone.asDriver()
            .map({ $0.abbreviation() })
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
        viewModel.fetchtimezoneDate.map({ $0.timeZone() }).filterNil().drive(selectedTimeZone).addDisposableTo(disposeBag)
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
        if let showSlectTimeZoneSegue = R.segue.timeZoneController.showSelectTimeZone(segue: segue) {
            showSlectTimeZoneSegue.destination.rx.selected
                .asDriver()
                .drive(selectedTimeZone)
                .addDisposableTo(disposeBag)
        }
    }


}

fileprivate extension Date {
    func timeZone() -> TimeZone? {
        return TimeZone(secondsFromGMT: Int(self.timeIntervalSince1970))
    }
}
