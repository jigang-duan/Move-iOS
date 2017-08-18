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
    
//    let selectedTimeZone = Variable("")
    let selectedTimeZoneSubject = PublishSubject<String>();
    
    let disposeBag = DisposeBag()
    
    private func internationalization() {
        timezoneTitleItem.title = R.string.localizable.id_time_zone()
        hoursFormatLabel.text = R.string.localizable.id_hours_format24()
        gettimeautoLabel.text = R.string.localizable.id_get_time_auto()
        timezoneLabel.text = R.string.localizable.id_time_zone()
        summerTimeLabel.text = R.string.localizable.id_summer_time()
    }
    
    func enableView(_ enable: Bool) {
        timezoneCell.isUserInteractionEnabled = !enable
        if !enable { //关闭
            timezoneCell.accessoryType = .disclosureIndicator
            self.summerTimeQutlet.isEnabled = true
        }else //打开的
        {
            timezoneCell.accessoryType = .none
            //发送一个请求关闭，且不能用
            self.summerTimeQutlet.isEnabled = false
            self.summerTimeQutlet.isOn = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //a开 b不能用,b开 再开a->b关掉&&b不能用
        internationalization()
        
        //auto on timecell off ,off on 控制跳转
        let openEnable = autoGetTimeQutlet.rx.switch.asDriver()
        openEnable.drive(onNext: {[weak self] in
            self?.enableView($0)
        }).addDisposableTo(disposeBag)
        
//        selectedTimeZone.asDriver().filterEmpty().debug()
//            .map({ " \($0)" })
//            .drive(timezoneCityQutlet.rx.text)
//            .addDisposableTo(disposeBag)
        
        let viewModel = TimeZoneViewModel(
            input: (
                hourform: hourFormatQutlet.rx.value.asDriver(),
                autotime: autoGetTimeQutlet.rx.value.asDriver(),
                selectedTimezone: selectedTimeZoneSubject.asDriver(onErrorJustReturn: ""),
                summertime: summerTimeQutlet.rx.value.asDriver()
            ),
            dependency: (
                settingsManager: WatchSettingsManager.share,
                validation: DefaultValidation.shared,
                configChanged: MessageServer.share.configChanged,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        viewModel.saveFinish
            .drive(onNext: {a in
                print("%@",a);
            }).addDisposableTo(disposeBag)

        viewModel.hourformEnable.drive(hourFormatQutlet.rx.on).addDisposableTo(disposeBag)
        viewModel.autotimeEnable.drive(autoGetTimeQutlet.rx.on).addDisposableTo(disposeBag)
//        viewModel.timezoneDate.drive(selectedTimeZone).addDisposableTo(disposeBag)
        viewModel.summertimeEnable.drive(summerTimeQutlet.rx.on).addDisposableTo(disposeBag)
        viewModel.autotimeEnable.drive(onNext: {[weak self] bool in
            self?.enableView(bool)
        }).addDisposableTo(disposeBag)
        
        viewModel.activityIn
            .map{ !$0 }
            .drive(onNext: {[weak self] in
                self?.userInteractionEnabled($0)
            })
            .addDisposableTo(disposeBag)

        viewModel.timezoneDate.map({ " \($0)" }).debug().drive(timezoneCityQutlet.rx.text).addDisposableTo(disposeBag)
    }
    
    func userInteractionEnabled(_ enable: Bool) {
      
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = R.segue.timeZoneController.showSelectTimeZone(segue: segue)?.destination {
            vc.selectedTimezone = { [weak self] index in
                self?.selectedTimeZoneSubject.onNext(index)
            }
        }
    }


}


