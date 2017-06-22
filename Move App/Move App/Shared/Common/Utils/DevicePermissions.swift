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
        
        let alert = UIAlertController(title: nil, message: "没有录音访问权限", preferredStyle: UIAlertControllerStyle.alert)
        let setting = UIAlertAction(title: "Settings", style: .default) { action in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }
        alert.addAction(setting)
        alert.addAction(UIAlertAction(title: "Clean", style: .default))
        return alert
    }
    
}
