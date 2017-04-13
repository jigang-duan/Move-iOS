//
//  MainMapController.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/9.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa
import SVPulsingAnnotationView
import Realm
import RealmSwift
import MessageUI
import CustomViews


class MainMapController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet var noGeolocationView: UIView!
    @IBOutlet weak var openPreferencesBtn: UIButton!
    
    @IBOutlet weak var callOutlet: UIButton!
    @IBOutlet weak var messageOutlet: UIButton!
    @IBOutlet weak var guideOutlet: UIButton!
    
    @IBOutlet weak var nameOutle: UILabel!
    @IBOutlet weak var addressOutlet: UILabel!
    @IBOutlet weak var timeOutlet: UILabel!
    @IBOutlet weak var headPortraitOutlet: UIButton!
    
    @IBOutlet weak var statesOutlet: UIImageView!
    @IBOutlet weak var voltameterOutlet: UILabel!
    @IBOutlet weak var voltameterImageOutlet: UIImageView!

    @IBOutlet weak var remindLocationOutlet: UIButton!
    
    let enterSubject = BehaviorSubject<Bool>(value: false)
    
    var isAtThisPage = Variable(false)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Location"
        self.isAtThisPage.value = true
        enterSubject.onNext(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isAtThisPage.value = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        noGeolocationView.frame = view.bounds
        view.addSubview(noGeolocationView)
        let geolocationService = GeolocationService.instance
        
        let wireframe = DefaultWireframe.sharedInstance
        
        let viewModel = MainMapViewModel(
            input: (
                enter: enterSubject.asDriver(onErrorJustReturn: false),
                avatarTap: headPortraitOutlet.rx.tap.asDriver(),
                avatarView: headPortraitOutlet,
                isAtThisPage: isAtThisPage,
                remindLocation: remindLocationOutlet.rx.tap.asObservable()
            ),
            dependency: (
                geolocationService: geolocationService,
                deviceManager: DeviceManager.shared,
                locationManager: LocationManager.share
            )
        )
        
        viewModel.allAction
            .bindNext({ [weak self] devices in
                self?.showAllKidsLocationController(data: devices)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.singleAction
            .map({ $0.deviceId })
            .filterNil()
            .bindTo(RxStore.shared.currentDeviceId)
            .addDisposableTo(disposeBag)
        
        viewModel.authorized
            .drive(noGeolocationView.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        openPreferencesBtn.rx.tap
            .bindNext { _ in
                wireframe.open(url: URL(string: UIApplicationOpenSettingsURLString)!)
            }
            .addDisposableTo(disposeBag)
        
        callOutlet.rx.tap.asDriver()
            .withLatestFrom(viewModel.currentDevice)
            .map({ URL(deviceInfo: $0) })
            .filterNil()
            .drive(onNext: {
                wireframe.open(url: $0)
            })
            .addDisposableTo(disposeBag)
        
        messageOutlet.rx.tap
            .bindNext { [unowned self] in
                if let chatController = R.storyboard.social.chat() {
                    self.navigationController?.show(chatController, sender: nil)
                }
            }
            .addDisposableTo(disposeBag)
        
        let name = viewModel.currentDevice.map { $0.user?.nickname }.filterNil()
        name.drive(nameOutle.rx.text).addDisposableTo(disposeBag)
        
        let nameAndLocation = Observable.combineLatest(name.asObservable(), viewModel.kidLocation)
        guideOutlet.rx.tap.asObservable()
            .withLatestFrom(nameAndLocation)
            .bindNext { [weak self] in
                self?.openPlacemark(name: $0.0, location: $0.1)
            }
            .addDisposableTo(disposeBag)
        
        viewModel.fetchDevices.drive(viewModel.devicesVariable).addDisposableTo(disposeBag)
        
        viewModel.currentDevice
            .drive(onNext: { [weak self] in
                self?.showHeadPortrait(deviceInfo: $0)
                self?.showVoltameterOutlet(deviceInfo: $0)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.currentProperty
            .withLatestFrom(viewModel.currentDevice) { (property, info) in DeviceInfo(property: property, info: info) }
            .withLatestFrom(viewModel.devicesVariable.asObservable()) { (info, infos) in transform(info: info, infos: infos) }
            .bindTo(viewModel.devicesVariable)
            .addDisposableTo(disposeBag)
        
        mapView.rx.willStartLoadingMap
            .asDriver()
            .drive(onNext: {
                Logger.debug("地图开始加载!")
            })
            .addDisposableTo(disposeBag)
        
        mapView.rx.didFinishLoadingMap
            .asDriver()
            .drive(onNext: {
                Logger.debug("地图结束加载!")
            })
            .addDisposableTo(disposeBag)
        
        mapView.rx.didAddAnnotationViews
            .asDriver()
            .drive(onNext: {
                Logger.debug("地图Annotion个数: \($0.count)")
            })
            .addDisposableTo(disposeBag)
        
        viewModel.kidAddress.bindTo(addressOutlet.rx.text).addDisposableTo(disposeBag)
        viewModel.locationTime
            .map({ $0.stringYearMonthDayHourMinuteSecond })
            .bindTo(timeOutlet.rx.text)
            .addDisposableTo(disposeBag)
        
        viewModel.kidLocation
            .bindNext({ [unowned self] in
                let region = MKCoordinateRegionMakeWithDistance($0, 500, 500)
                self.mapView.setRegion(region, animated: true)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.kidAnnotion
            .distinctUntilChanged()
            .bindNext({ [unowned self] annotion in
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotation(annotion)
            })
            .addDisposableTo(disposeBag)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = R.segue.mainMapController.locationHistory(segue: segue)?.destination {
            if let device = DeviceManager.shared.currentDevice {
                vc.Sprofile = device.user?.profile
                vc.Snikename = device.user?.nickname
                vc.deviceId = device.deviceId
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func StatesChange(code : Int)  {
        let info = MoveApi.DeviceSendNotify(code : 1 , value : nil)
        MoveApi.Device.sendNotify(deviceId: (DeviceManager.shared.currentDevice?.deviceId)!, sendInfo: info)
            .subscribe({ event in
                switch event{
                case .next(let numbers):
                    print(numbers)
                    break
                case .completed:
                    break
                case .error(let er):
                    print(er)
                }
                }).addDisposableTo(self.disposeBag)
        if code == 10 {
            self.statesOutlet.image = R.image.home_ic_wear()
        }else if code == 11 {
            self.statesOutlet.image = R.image.home_ic_nottowear()
        }
    }
    
}


extension MainMapController {
    
    fileprivate func showAllKidsLocationController(data: [DeviceInfo]) {
        if let toVC = R.storyboard.major.allKidsLocationVC() {
            toVC.dataArr = data
            self.navigationController?.show(toVC, sender: nil)
        }
    }
    
    fileprivate func showVoltameterOutlet(deviceInfo: DeviceInfo) {
        if let power = deviceInfo.property?.power {
            voltameterOutlet.text = "\(power)%"
            voltameterImageOutlet.image = UIImage(named: "home_ic_battery\(power/20)")
        }
    }

    fileprivate func showHeadPortrait(deviceInfo: DeviceInfo) {
        let placeImg = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0,
                                                      width: headPortraitOutlet.frame.size.width,
                                                      height: headPortraitOutlet.frame.size.height),
                                         fullName: deviceInfo.user?.nickname ?? "" )
            .imageRepresentation()!
        
        let imgUrl = deviceInfo.user?.profile?.fsImageUrl.url
        self.headPortraitOutlet.kf.setBackgroundImage(with: imgUrl, for: .normal, placeholder: placeImg)
    }
}


extension MainMapController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is BaseAnnotation {
            let identifier = "LocationAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = SVPulsingAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            annotationView?.canShowCallout = false
            return annotationView
        }
        
        return nil
    }
    
    fileprivate func openPlacemark(name: String, location: CLLocationCoordinate2D) {
        let options = [ MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking ]
        let placemark = MKPlacemark(coordinate: location, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: options)
    }
}

extension MainMapController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
        switch result{
        case .sent :
            Logger.debug("短信已发送")
        case .cancelled:
            Logger.debug("短信取消发送")
        case .failed:
            Logger.debug("短信发送失败")
        }
    }
}

fileprivate func transform(info: DeviceInfo, infos: [DeviceInfo]) -> [DeviceInfo] {
    var devices = infos
    if let index = infos.index(where: { $0.deviceId == info.deviceId }) {
        devices[index] = info
    }
    return devices
}

fileprivate extension DeviceInfo {

    init(property: DeviceProperty, info: DeviceInfo) {
        self.init()
        self = info
        self.property = property
    }
}


fileprivate extension String {
    var url: URL? {
        return URL(string: self)
    }
}

fileprivate extension URL {
    init?(deviceInfo: DeviceInfo) {
        guard let number = deviceInfo.user?.number else {
            return nil
        }
        let phone = "telprompt://\(number)".replacingOccurrences(of: " ", with: "")
        self.init(string: phone)
    }
}
