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
    
    func audioPermissionsAlert() -> (Bool, UIAlertController?) {
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio)
        switch authStatus {
        case .authorized:
            return (true, nil)
        case .notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio) { (granted) in }
            return (false, nil)
        case .denied, .restricted:
            return (false, buildAudioPermissionsAlert())
        }
    }
    
    private func buildAudioPermissionsAlert() -> UIAlertController {
        let message = R.string.localizable.id_open_microphone_request().specifiedText
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let setting = UIAlertAction(title: R.string.localizable.id_action_settings(), style: .default) { action in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }
        alert.addAction(setting)
        alert.addAction(UIAlertAction(title: R.string.localizable.id_cancel(), style: .default))
        return alert
    }
    
}
