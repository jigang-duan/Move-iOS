//
//  MapNavigateActionSheet.swift
//  Move App
//
//  Created by tcl on 2017/6/30.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class MapNavigateActionSheet: NSObject, UIActionSheetDelegate {
    
    private var maps: [[String: String]] = []
    
    func show(endLocation: CLLocationCoordinate2D, title: String, atView: UIView) {
        getInstallMapAppWithEndLocation(endLocation: endLocation)
        
        let actionSheet = UIActionSheet()
        actionSheet.title = title
        maps.forEach { actionSheet.addButton(withTitle: $0["title"]) }
        actionSheet.cancelButtonIndex = 0
        actionSheet.delegate = self
        actionSheet.show(in: atView)
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        if (buttonIndex != -1) {
            if (buttonIndex == 0) {
                print("打开苹果地图")
                return
            }
            let dic = maps[buttonIndex-1]
            if let urlString = dic["url"], let url = URL(string: urlString) {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func getInstallMapAppWithEndLocation(endLocation:CLLocationCoordinate2D)  {
        
        //苹果地图
        maps.append(["title":"apple Map"])
        
        //百度地图
        if let url = URL(string: "baidumap://"), UIApplication.shared.canOpenURL(url) {
            if let urlString = String(format: "baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=北京&mode=driving&coord_type=gcj02",endLocation.latitude,endLocation.longitude)
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                maps.append(["title": "baidu Map","url": urlString])
            }
        }
        
        //高德地图
        if let url = URL(string: "iosamap://"), UIApplication.shared.canOpenURL(url) {
            if let urlString = String(format: "iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%f&lon=%f&dev=0&style=2","导航功能", endLocation.latitude, endLocation.longitude)
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                maps.append(["title": "AMap Map","url": urlString])
            }
        }
        
        //google地图
        if let url = URL(string: "comgooglemaps://"), UIApplication.shared.canOpenURL(url) {
            if let urlString = String(format: "comgooglemaps://?x-source=%@&x-success=%@&saddr=&daddr=%f,%f&directionsmode=driving","导航测试","nav123456",endLocation.latitude, endLocation.longitude)
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                maps.append(["title":"google Map","url":urlString])
            }
        }
    }
}
