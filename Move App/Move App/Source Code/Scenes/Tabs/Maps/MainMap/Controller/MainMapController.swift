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
//import AFImageHelper
import CustomViews
//private extension Reactive where Base: MKMapView {
//    var singleAnnotion: UIBindingObserver<Base, MKAnnotation> {
//        return UIBindingObserver(UIElement: base) { mapView, annotion in
//            mapView.removeAnnotations(mapView.annotations)
//            mapView.addAnnotation(annotion)
//        }
//    }
//}

class MainMapController: UIViewController , MFMessageComposeViewControllerDelegate{
    
    var curDirectionMode:MKDirectionsTransportType = .walking

    var disposeBag = DisposeBag()
    var isOpenList : Bool? = false
    var defaultDeviceData : [MoveApi.DeviceInfo]? = []
    
    var userPoint : CLLocationCoordinate2D?
    var selectPoint : CLLocationCoordinate2D?
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet var noGeolocationView: UIView!
    @IBOutlet weak var openPreferencesBtn: UIButton!
    
    @IBOutlet weak var objectImageBtn: UIButton!
    @IBOutlet weak var objectNameL: UILabel!
    @IBOutlet weak var objectNameLConstraintWidth: NSLayoutConstraint!
    @IBOutlet weak var objectLocationL: UILabel!
    @IBOutlet weak var signalImageV: UIImageView!
    @IBOutlet weak var electricV: UIImageView!
    @IBOutlet weak var electricL: UILabel!
    @IBOutlet weak var objectLocationTimeL: UILabel!
    
    var currentDeviceData : BasePopoverAction?
    
    var accountViewModel: AccountAndChoseDeviceViewModel!
    let enterCount = Variable(0)
    
    var isAtThisPage = Variable(false)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.title = "Location"
        self.isAtThisPage.value = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isAtThisPage.value = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getDataSource()
        noGeolocationView.frame = view.bounds
        view.addSubview(noGeolocationView)
        let geolocationService = GeolocationService.instance
        
        let viewModel = MainMapViewModel(
            input: (
                avatarTap: objectImageBtn.rx.tap.asDriver(),
                avatarView: objectImageBtn,
                isAtThisPage: isAtThisPage.asDriver()
            ),
            dependency: (
                geolocationService: geolocationService,
                deviceManager: DeviceManager.shared,
                locationManager: LocationManager.share
            )
        )
        
        viewModel.selecedAction
            .bindNext({
                Logger.info($0)
                let device : MoveApi.DeviceInfo? = $0.data as? MoveApi.DeviceInfo
                print("\(device)")
                self.KidInfoToAnimation(dataSource: $0)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.authorized
            .drive(noGeolocationView.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        openPreferencesBtn.rx.tap
            .bindNext { [weak self] in
                self?.openAppPreferences()
            }
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
        
        viewModel.kidLocation
            .drive(onNext: { [unowned self] in
                let region = MKCoordinateRegionMakeWithDistance($0, 500, 500)
                self.mapView.setRegion(region, animated: true)
                self.GetCurrentNew()
            })
            .addDisposableTo(disposeBag)
        
        viewModel.kidAnnotion
            .distinctUntilChanged()
            .drive(onNext: { [unowned self] annotion in
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotation(annotion)
        })
            .addDisposableTo(disposeBag)
        
    }
    
    @IBAction func locationBtnClick(_ sender: UIButton) {
        if (currentDeviceData != nil) {
           self.GetCurrentNew()
        }
    }
    
    func GetCurrentNew() {
        let getaddressdata = MoveApi.Location.getNew(deviceId: Me.shared.currDeviceID!)
            .map({
                let annotation = BaseAnnotation(($0.location?.lat)!, ($0.location?.lng)!)
                self.objectLocationL.text = $0.location?.addr
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotation(annotation)
            })
        getaddressdata.subscribe(onNext: {
            print($0)
        }).addDisposableTo(disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "LocationHistory" {
            if (currentDeviceData != nil) {
                let device : MoveApi.DeviceInfo = self.currentDeviceData?.data as! MoveApi.DeviceInfo
                //主要就是通过类型强转,然后通过拿到的对象进行成员变量的赋值,相对于Android,这真的是简单粗暴
                let nav2Controller = segue.destination as! LocationHistoryVC
                nav2Controller.Sprofile = device.user?.profile
                nav2Controller.Snikename = device.user?.nickname
                nav2Controller.deviceId = device.deviceId
            }
        }
    }
    
    @IBAction func MobilePhoneBtnClick(_ sender: UIButton) {
        if (currentDeviceData != nil) {
            let device : MoveApi.DeviceInfo = currentDeviceData?.data as! MoveApi.DeviceInfo
            if (device.user != nil) {
                let str : String = "telprompt://" + (device.user?.number)!
                UIApplication.shared.openURL(URL(string: str)!)
            }
        }
    }
    
    @IBAction func MobileMessageBtnClick(_ sender: UIButton) {

        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        let chatViewController = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
        
        self.navigationController?.pushViewController(chatViewController!, animated: true)
    }
    
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
        switch result{
            case MessageComposeResult.sent :
            print("短信已发送")
            
            case MessageComposeResult.cancelled:
            print("短信取消发送")
            
            case MessageComposeResult.failed:
            print("短信发送失败")
            
        default :
            print("没有匹配的")
        }
    }
    
    @IBAction func GuideToWalk(_ sender: UIButton) {
        
        if mapView.annotations.count > 0 {
            for annotation in mapView.annotations {
                if annotation is BaseAnnotation {
                    let kidCoordinate = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
                    let options = [
                        MKLaunchOptionsDirectionsModeKey: self.curDirectionMode == .walking ? MKLaunchOptionsDirectionsModeWalking : MKLaunchOptionsDirectionsModeDriving,
                        ]
                    let placemark = MKPlacemark(coordinate: kidCoordinate, addressDictionary: nil)
                    let mapItem = MKMapItem(placemark: placemark)
                    mapItem.name = "\(self.objectNameL.text ?? "")"
                    mapItem.openInMaps(launchOptions: options)
                }
            }
            
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func openAppPreferences() {
        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
    }
    
    
    func getDataSource() {
        let deviceDataSource = MoveApi.Device.getDeviceList(pid: 0)
            .map({
                self.defaultDeviceData = $0.devices
                
                if let data = self.defaultDeviceData?.first {
                    self.UpdateUIData(dataSource: data)
                    
                    let action = BasePopoverAction(imageUrl: data.user?.profile,
                                                   placeholderImage: R.image.home_pop_all(),
                                                   title: data.user?.nickname,
                                                   isSelected: true,
                                                   handler: nil)
                    action.canAvatar = true
                    action.data = data
                    self.currentDeviceData = action
                    let device : MoveApi.DeviceInfo = self.currentDeviceData?.data as! MoveApi.DeviceInfo
                    let placeImg = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: 54, height: 54), fullName: device.user?.nickname ?? "" ).imageRepresentation()!
                    
                    let imgUrl = URL(string: FSManager.imageUrl(with: device.user?.profile ?? ""))
                    self.objectImageBtn.kf.setBackgroundImage(with: imgUrl, for: .normal, placeholder: placeImg)
                }
                
            })
        deviceDataSource.subscribe(onNext: {
            print($0)
        }).addDisposableTo(disposeBag)
        
    }
    
    func UpdateUIData(dataSource : MoveApi.DeviceInfo){
        objectNameL.text = dataSource.user?.nickname
        
        let devicePower = MoveApi.Device.getPower(deviceId: dataSource.deviceId!)
            .map({
                self.changepower(power: $0.power!)
            })
        devicePower.subscribe(onNext: {
            print($0)
        }).addDisposableTo(disposeBag)
        
        let getaddressdata = MoveApi.Location.getNew(deviceId: dataSource.deviceId!)
            .map({
                self.objectLocationL.text = $0.location?.addr
                self.objectLocationTimeL.text = $0.location?.time?.stringYearMonthDayHourMinuteSecond
            })
        getaddressdata.subscribe(onNext: {
            print($0)
        }).addDisposableTo(disposeBag)
        
        if dataSource.property != nil {
            let property : MoveApi.DeviceProperty = (dataSource.property)!
            let power = (property.power)!
            self.changepower(power: power)
        }
    }
    
    func changepower(power : Int) {
        electricL.text = String(format:"%d%@",power,"%")
        if power == 0{
            signalImageV.image = UIImage(named: "home_ic_battery0")
        }else if power < 20 && power > 0{
            signalImageV.image = UIImage(named: "home_ic_battery1")
        }else if power < 40 && power > 20 {
            signalImageV.image = UIImage(named: "home_ic_battery2")
        }else if power < 60 && power > 40 {
            signalImageV.image = UIImage(named: "home_ic_battery3")
        }else if power < 80 && power > 60 {
            signalImageV.image = UIImage(named: "home_ic_battery4")
        }else if power < 100 && power > 80 {
            signalImageV.image = UIImage(named: "home_ic_battery5")
        }
    }
    
    func KidInfoToAnimation(dataSource : BasePopoverAction) {
        if dataSource.title == "ALL" {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AllKidsLocationVC") as! AllKidsLocationVC
            vc.dataArr = dataSource.data as! NSArray
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            objectNameL.text = dataSource.title
            self.currentDeviceData = dataSource
            
            let device : MoveApi.DeviceInfo? = dataSource.data as? MoveApi.DeviceInfo
            let placeImg = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: 54, height: 54), fullName: device?.user?.nickname ?? "" ).imageRepresentation()!
            
            let imgUrl = URL(string: FSManager.imageUrl(with: device?.user?.profile ?? ""))
            self.objectImageBtn.kf.setBackgroundImage(with: imgUrl, for: .normal, placeholder: placeImg)
            if device?.property != nil {
                let property : MoveApi.DeviceProperty = (device?.property)!
                let power = (property.power)!
                self.changepower(power: power)
            }
        }
    }
}

fileprivate extension UIImage {
    
    func scale(toSize: CGSize) -> UIImage? {
        
        UIGraphicsBeginImageContext(toSize)
        
        self.draw(in: CGRect.init(x: 0, y: 0, width: toSize.width, height: toSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}
extension MainMapController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is BaseAnnotation {
            let identifier = "LocationAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = ContactAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            let device : MoveApi.DeviceInfo = currentDeviceData?.data as! MoveApi.DeviceInfo
            (annotationView as! ContactAnnotationView).setAvatarImage(nikename: (device.user?.nickname)!, profile: (device.user?.profile)!)            
            annotationView?.canShowCallout = false
            return annotationView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //        let render = MKPolygonRenderer(overlay: overlay)
        //        render.strokeColor = UIColor.redColor()
        //        render.lineWidth = 4.0
        //        return render
        //        if overlay is MKPolyline {
        let  polylineRenderer = MKPolylineRenderer(overlay: overlay)
        //      polylineRenderer.lineDashPattern = [14,10,6,10,4,10]
        polylineRenderer.strokeColor = UIColor.red
        //      polylineRenderer.strokeColor = UIColor(red: 0.012, green: 0.012, blue: 0.012, alpha: 1.00)
        polylineRenderer.fillColor = UIColor.blue
        polylineRenderer.lineWidth = 2.5
        return polylineRenderer
    }
}
