//
//  ImageUtility.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/18.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import AVFoundation



class ImageUtility: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    private var target: UIViewController?
    private var photoCallback: ((UIImage) -> Void)?
    private var imageSize = CGSize(width: 0, height: 0)
    
    
    func selectPhoto(with target: UIViewController, soureType: UIImagePickerControllerSourceType, size: CGSize = CGSize(width: 0, height: 0), callback: @escaping (((UIImage) -> Void))) {
        self.target = target
        self.photoCallback = callback
        self.imageSize = size
        
        if cameraPermissions() {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = true
            if UIImagePickerController.isSourceTypeAvailable(soureType) {
                imagePickerController.sourceType = soureType
                self.target?.present(imagePickerController, animated: true)
            }
        }else{
            let vc = UIAlertController(title: nil, message: "没有相机/照片访问权限", preferredStyle: UIAlertControllerStyle.alert)
            let action1 = UIAlertAction(title: "Settings", style: .default) { action in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            }
            let action2 = UIAlertAction(title: "Ok", style: .default)
            vc.addAction(action1)
            vc.addAction(action2)
            self.target?.present(vc, animated: true)
        }
    }

    
    
    private func cameraPermissions() -> Bool {
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if(authStatus == .denied || authStatus == .restricted) {
            return false
        }
        return true
    }
    
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true){
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                let img = self.compressImage(with: image, size: self.imageSize)
                if self.photoCallback != nil {
                    self.photoCallback!(img)
                }
            }
        }
    }
    
    
    func compressImage(with image: UIImage, size: CGSize) -> UIImage {
        if size == CGSize(width: 0, height: 0) {
            return image
        }
        
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        var img = UIImage()
        if let tempImg = UIGraphicsGetImageFromCurrentImageContext() {
            img = tempImg
        }
        UIGraphicsEndImageContext()
        return img
    }
    
}

