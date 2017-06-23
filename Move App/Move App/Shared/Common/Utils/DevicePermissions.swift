//
//  DevicePermissions.swift
//  Move App
//
//  Created by jiang.duan on 2017/6/22.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import AVFoundation

class DevicePermissions {
    
    func getCurrentLanguage() -> String {
        let preferredLang = Bundle.main.preferredLocalizations.first! as NSString
        switch String(describing: preferredLang) {
        case "en-US", "en-CN":
            return "en"//英文
        case "zh-Hans-US","zh-Hans-CN","zh-Hant-CN","zh-TW","zh-HK","zh-Hans":
            return "cn"//中文
        default:
            return "en"
        }
    }
    
    var audioPermissions: Bool {
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio)
        switch authStatus {
        case .authorized, .notDetermined:
            return true
        case .denied, .restricted:
            return false
        }
    }
    
    func audioPermissionsAlert() -> UIAlertController? {
        if audioPermissions {
            return nil
        }
        
        let strLanguage = self.getCurrentLanguage()
        var strAlertTitle :String = ""
        if  strLanguage == "cn"{
            strAlertTitle = "没有录音访问权限"
        }else{
            strAlertTitle = "NO Microphone access permissions"
        }

        
        let alert = UIAlertController(title: nil, message: strAlertTitle, preferredStyle: UIAlertControllerStyle.alert)
        let setting = UIAlertAction(title: "Settings", style: .default) { action in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }
        alert.addAction(setting)
        alert.addAction(UIAlertAction(title: "Clean", style: .default))
        return alert
    }
    
}
