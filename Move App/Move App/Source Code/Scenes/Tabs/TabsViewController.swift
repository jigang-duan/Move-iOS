//
//  TabsViewController.swift
//  Move App
//
//  Created by Jiang Duan on 17/1/20.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import RxSwift
import RxCocoa

class TabsViewController: UITabBarController {
    
    let enterSubject = PublishSubject<Void>()
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ThemeManager.applyNavigationBar(theme: ThemeManager.currentTheme())
        
        viewControllers = [
            R.storyboard.major.navHomeController()!,
            R.storyboard.main.choseDevice()!
            //R.storyboard.social.instantiateInitialViewController()!
        ]
        
        viewControllers?.first?.tabBarItem.title = R.string.localizable.id_button_menu_home()
        viewControllers?.last?.tabBarItem.title = R.string.localizable.id_button_menu_account()
        
//        let hasDevice = RxStore.shared.deviceInfosState.asObservable()
//            .map({ $0.count > 0 })
//        
//        hasDevice.bindNext({[weak self] in
//                self?.viewControllers?[0].tabBarItem.isEnabled = $0
//            })
//            .addDisposableTo(bag)
//
//        hasDevice.filter { !$0 }
//            .bindNext { [weak self] _ in
//                self?.selectedIndex = 1
//            }
//            .addDisposableTo(bag)
        
        MessageServer.share.syncDataInitalization(disposeBag: bag)
        MessageServer.share.subscribe().addDisposableTo(bag)
        AlertServer.share.subscribe(disposeBag: bag)
        
        SOSService.shared.subject
            .flatMapLatest(transform)
            .flatMapLatest(transform)
            .bindNext({ [weak self] in
                self?.showSOSViewController(sos: $0)
            })
            .addDisposableTo(bag)
        
        let cacheDevID = RxStore.shared.deviceInfosState.asObservable().filterEmpty()
            .withLatestFrom(DataCacheManager.shared.rx.get(key: "key.id.device.current", default: "")) { (devices, id) in
                devices.filter{ $0.deviceId == id }.first?.deviceId ?? devices.first?.deviceId
            }
        RxStore.shared.deviceInfosState.asObservable()
            .withLatestFrom(RxStore.shared.currentDeviceId.asObservable()) { (devices, id) in
                devices.filter{ $0.deviceId == id }.first?.deviceId
            }
            .filter { $0 == nil }
            .flatMapLatest { _ in cacheDevID.asDriver(onErrorJustReturn: nil).filterNil() }
            .distinctUntilChanged()
            .bindTo(RxStore.shared.currentDeviceId)
            .addDisposableTo(bag)
        
        AlertServer.share.unpiredSubject.asObservable()
            .flatMapLatest { DeviceManager.shared.fetchDevices() }
            .bindTo(RxStore.shared.deviceInfosState)
            .addDisposableTo(bag)
        
        RxStore.shared.deviceIdObservable
            .distinctUntilChanged()
            .subscribe(DataCacheManager.shared.rx.set(key: "key.id.device.current"))
            .addDisposableTo(bag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enterSubject.onNext(())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


fileprivate func transform(lbs: KidSate.SOSLbsModel) -> Observable<KidSateSOS> {
    let fetchSOS = LocationManager.share.fetch(lbs: lbs)
    if let imei = lbs.imei {
        if let location = lbs.location {
            return fetchSOS.catchErrorJustReturn(KidSateSOS.gps(imei: imei, location: location))
        }
        return fetchSOS.catchErrorJustReturn(KidSateSOS.imei(imei))
    } else {
        return fetchSOS.catchErrorJustReturn(KidSateSOS.empty())
    }
}

fileprivate func transform(sos: KidSateSOS) -> Observable<KidSateSOS> {
    guard let deviceId = sos.imei else {
        return Observable.just(KidSateSOS.empty())
    }
    return DeviceManager.shared.fetchDevice(id: deviceId)
        .map({ sos.clone(deviceInof: $0) })
        .catchErrorJustReturn(sos)
}


extension TabsViewController {

    fileprivate func showSOSViewController(sos: KidSateSOS) {
        if let toVC = R.storyboard.social.showSOS() {
            if let sosVC = toVC.viewControllers.first as? SOSController {
                sosVC.sos = sos
            }
            self.present(toVC, animated: true, completion: nil)
        }
    }
}
