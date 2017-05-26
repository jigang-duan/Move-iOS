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
    
    let enterSubject = BehaviorSubject<Bool>(value: false)
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewControllers = [
            R.storyboard.major.navHomeController()!,
            R.storyboard.main.choseDevice()!
            //R.storyboard.social.instantiateInitialViewController()!
        ]
        
        let hasDevice = RxStore.shared.deviceInfosState.asObservable()
            .map({ $0.count > 0 })
        
        hasDevice.bindNext({[weak self] in
                self?.viewControllers?[0].tabBarItem.isEnabled = $0
            })
            .addDisposableTo(bag)
        
//        let nonOrOneDevice = RxStore.shared.deviceInfosState.asObservable().filter({ $0.count <= 1 }).map({ $0.first?.deviceId })
//        nonOrOneDevice.distinctUntilChanged().bindTo(RxStore.shared.currentDeviceId).addDisposableTo(bag)
        
        enterSubject.asObservable()
            .filter({$0})
            .withLatestFrom(hasDevice)
            .filter({ !$0 })
            .bindNext({ [weak self] _ in
                self?.selectedIndex = 1
            })
            .addDisposableTo(bag)
        
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
        
        RxStore.shared.deviceInfosState.asObservable()
            .withLatestFrom(RxStore.shared.currentDeviceId.asObservable()) { (devices, id) in
                devices.filter({ $0.deviceId == id }).first?.deviceId
            }
            .filter { $0 == nil }
            .flatMapLatest { (_) in
                DeviceManager.shared.fetchDevices().map{ $0.first?.deviceId }.catchErrorJustReturn(nil).filterNil()
            }
            .bindTo(RxStore.shared.currentDeviceId)
            .addDisposableTo(bag)
        
        AlertServer.share.unpiredSubject.asObservable()
            .flatMapLatest { DeviceManager.shared.fetchDevices().catchErrorJustReturn([]) }
            .bindTo(RxStore.shared.deviceInfosState)
            .addDisposableTo(bag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enterSubject.onNext(true)
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
            toVC.sos = sos
            self.present(toVC, animated: true, completion: nil)
        }
    }
}
