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
import AFImageHelper
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
    
    var disposeBag = DisposeBag()
    var isOpenList : Bool? = false
    
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
    
    var isAtThisPage = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.title = "Location"
        self.isAtThisPage = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isAtThisPage = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noGeolocationView.frame = view.bounds
        view.addSubview(noGeolocationView)
        let geolocationService = GeolocationService.instance
        
        let viewModel = MainMapViewModel(
            input: (
                avatarTap: objectImageBtn.rx.tap.asDriver(),
                avatarView: objectImageBtn,
                isAtThisPage: isAtThisPage
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
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "LocationHistory" {
            if (currentDeviceData != nil) {
                let device : MoveApi.DeviceInfo = currentDeviceData?.data as! MoveApi.DeviceInfo
                //主要就是通过类型强转,然后通过拿到的对象进行成员变量的赋值,相对于Android,这真的是简单粗暴
                let nav2Controller = segue.destination as! LocationHistoryVC
                nav2Controller.deviceId = device.deviceId
            }
        }
    }
    
    @IBAction func MobilePhoneBtnClick(_ sender: UIButton) {
        if (currentDeviceData != nil) {
            let device : MoveApi.DeviceInfo = currentDeviceData?.data as! MoveApi.DeviceInfo
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string:(device.user?.number)!)!, options: ["":""], completionHandler: nil)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    @IBAction func MobileMessageBtnClick(_ sender: UIButton) {
        if (currentDeviceData != nil) {
            if MFMessageComposeViewController.canSendText(){
                let controller = MFMessageComposeViewController()
                //设置短信内容
                controller.body = ""
                //设置收件人列表
                let device : MoveApi.DeviceInfo = currentDeviceData?.data as! MoveApi.DeviceInfo
                controller.recipients = [(device.user?.number)!]
                //设置代理
                controller.messageComposeDelegate = self
                //打开界面
                self.present(controller, animated: true, completion: { () -> Void in
                    
                })
            }else{
                print("本设备不能发送短信")
            }
        }
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
        mapView.removeOverlays(mapView.overlays)
        if (userPoint == nil || selectPoint == nil ){
            return
        }
        self.goSearch(fromCoordinate: userPoint!, tofromCoordinate: selectPoint!)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func openAppPreferences() {
        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
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
            self.setObjectImageBtn(UIImage( named: "member_btn_contact_pre"), title: (device?.user?.nickname)!, imageUrl: device?.user?.profile)
            if device?.property != nil {
                let property : MoveApi.DeviceProperty = (device?.property)!
                let power = (property.power)!
                
                electricL.text = String(format:"%d%",(property.power)!)
                if power == 0{
                    electricV.image = UIImage(named: "home_ic_battery0")
                }else if power < 20 && power > 0{
                    electricV.image = UIImage(named: "home_ic_battery1")
                }else if power < 40 && power > 20 {
                    electricV.image = UIImage(named: "home_ic_battery2")
                }else if power < 60 && power > 40 {
                    electricV.image = UIImage(named: "home_ic_battery3")
                }else if power < 80 && power > 60 {
                    electricV.image = UIImage(named: "home_ic_battery4")
                }else if power < 100 && power > 80 {
                    electricV.image = UIImage(named: "home_ic_battery5")
                }
            }
        }
    }
    
    
    func goSearch(fromCoordinate:CLLocationCoordinate2D ,tofromCoordinate : CLLocationCoordinate2D){
        let fromPlaceMark = MKPlacemark(coordinate: fromCoordinate, addressDictionary: nil)
        let toPlaceMark = MKPlacemark(coordinate: tofromCoordinate, addressDictionary: nil)
        let fromItem = MKMapItem(placemark: fromPlaceMark)
        let toItem = MKMapItem(placemark: toPlaceMark)
        self.findDirectionsFrom(source: fromItem, destination: toItem)
    }
    
    func findDirectionsFrom(source:MKMapItem,destination:MKMapItem){
        let request = MKDirectionsRequest()
        request.source = source
        request.destination = destination
        request.transportType = MKDirectionsTransportType.walking
        request.requestsAlternateRoutes = true;
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if error == nil {
                self.showRoute(response: response!)
            }else{
                print("trace the error \(error?.localizedDescription)")
            }
        }
    }
    
    func showRoute(response:MKDirectionsResponse) {
        for route in response.routes {
            mapView.add(route.polyline,level: MKOverlayLevel.aboveRoads)
            let routeSeconds = route.expectedTravelTime
            let routeDistance = route.distance
            print("distance between two points is \(routeSeconds) and \(routeDistance)")
        }
    }
    
    private func convert(image: UIImage?, size: CGSize) -> UIImage? {
        return image?.scale(toSize: size)?.roundCornersToCircle()
    }
    
    private func conver(title: String, size: CGSize) -> UIImage? {
        return CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height),
                                 fullName: title).imageRepresentation()
    }
    
    func setObjectImageBtn(_ placeholderImage: UIImage?, title: String, imageUrl: String?) {
        
        guard let placeholder = placeholderImage else {
            return
        }
        
        let showImage = self.conver(title: title, size: placeholder.size) ?? placeholder
        guard let url = imageUrl else {
            self.objectImageBtn.setImage(self.convert(image: showImage, size: placeholder.size), for: .normal)
            return
        }
        
        let image = UIImage.image(fromURL: url,
                                  placeholder: showImage) { [weak self] in
                                    if let image = $0 {
                                        self?.objectImageBtn.setImage(self?.convert(image: image, size: placeholder.size), for: .normal)
                                    }
        }
        self.objectImageBtn.setImage(self.convert(image: image, size: placeholder.size), for: .normal)
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
