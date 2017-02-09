//
//  MainMapSceneViewController.swift
//  Move App
//
//  Created by lx on 17/2/8.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MainMapSceneViewController: UIViewController  {

    @IBOutlet weak var mainMapView: MKMapView!
    
    var locationManager : CLLocationManager!
    var currLocation : CLLocation!
    var isfirstlocation : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainMapView.delegate = self
        //初始化位置管理器
        locationManager = CLLocationManager()
        locationManager.delegate = self
        //设备使用电池供电时最高的精度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //精确到1000米,距离过滤器，定义了设备移动后获得位置信息的最小距离
        locationManager.distanceFilter = kCLLocationAccuracyKilometer
        if ios8(){
            //如果是IOS8及以上版本需调用这个方法
            locationManager.requestAlwaysAuthorization()
            //使用应用程序期间允许访问位置数据
            locationManager.requestWhenInUseAuthorization();
            //启动定位
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func ios8() -> Bool {
        let versionCode:String = UIDevice.current.systemVersion
        let version = NSString(string:  versionCode).doubleValue
        return version >= 8.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension MainMapSceneViewController :  MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print("地图缩放级别发送改变时")
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("地图缩放完毕触法")
    }
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        print("开始加载地图")
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        print("地图加载结束")
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        print("地图加载失败")
    }
    
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        print("开始渲染下载的地图块")
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        print("渲染下载的地图结束时调用")
    }
    
    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
        print("正在跟踪用户的位置")
    }
    
    func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
        print("停止跟踪用户的位置")
    }
    
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        print("跟踪用户的位置失败")
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode,
                 animated: Bool) {
        print("改变UserTrackingMode")
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("设置overlay的渲染")
        return MKPolylineRenderer()
    }
    
    private func mapView(mapView: MKMapView, didAddOverlayRenderers renderers: [MKOverlayRenderer]) {
        print("地图上加了overlayRenderers后调用")
    }
    
    /*** 下面是大头针标注相关 *****/
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        print("添加注释视图")
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        print("点击注释视图按钮")
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("点击大头针注释视图")
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("取消点击大头针注释视图")
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 didChange newState: MKAnnotationViewDragState,
                 fromOldState oldState: MKAnnotationViewDragState) {
        print("移动annotation位置时调用")
    }

}

extension MainMapSceneViewController : CLLocationManagerDelegate{
    func  locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location:CLLocation = locations[locations.count-1] as CLLocation
        currLocation = location
        if (location.horizontalAccuracy > 0) {
            //self.locationManager.stopUpdatingLocation()
            print("wgs84坐标系  纬度: \(location.coordinate.latitude) 经度: \(location.coordinate.longitude)")
            // self.locationManager.stopUpdatingLocation()
            //print("结束定位")
        }
        
        if isfirstlocation == false {
            let latDelta = 0.05
            let longDelta = 0.05
            let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
            let center:CLLocation = CLLocation(latitude: location.coordinate.latitude , longitude: location.coordinate.longitude)
            let currentRegion:MKCoordinateRegion = MKCoordinateRegion(center: center.coordinate,
                                                                      span: currentLocationSpan)
            mainMapView.setRegion(currentRegion, animated: true)
            isfirstlocation = true
        }
    }
    //FIXME:  获取位置信息失败
    func  locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
