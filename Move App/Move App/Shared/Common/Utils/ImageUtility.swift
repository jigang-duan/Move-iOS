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
    
    
    func selectPhoto(with target: UIViewController, callback: @escaping (((UIImage) -> Void)), size: CGSize = CGSize(width: 0, height: 0) ) {
        self.target = target
        self.photoCallback = callback
        self.imageSize = size
        
        if cameraPermissions() {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = true
            imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.target?.present(imagePickerController, animated: true, completion: nil)
        }else{
            self.showMessage("没有相机权限")
        }
    }

    
    
    private func cameraPermissions() -> Bool {
        let authStatus:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if(authStatus == AVAuthorizationStatus.denied || authStatus == AVAuthorizationStatus.restricted) {
            return false
        }
        return true
    }
    
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let img = self.compressImage(with: image, size: self.imageSize)
            if self.photoCallback != nil {
                self.photoCallback!(img)
            }
        }
        picker.dismiss(animated: true) {
            
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
    
    
    
    private func showMessage(_ text: String) {
        let vc = UIAlertController.init(title: "提示", message: text, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        vc.addAction(action)
        self.target?.present(vc, animated: true) {
            
        }
    }
}

