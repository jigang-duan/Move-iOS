//
//  ScanCodeController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/13.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import AVFoundation
import RxSwift

class ScanCodeController: UIViewController {

    //会话
    lazy var session: AVCaptureSession = AVCaptureSession()
    
    //输入设备
    private lazy var deviceInput: AVCaptureDeviceInput = {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do{
            let input = try AVCaptureDeviceInput(device: device)
            return input
        }catch{
            print(error)
            return AVCaptureDeviceInput()
        }
        
    }()
    //输出设备
    private lazy var output: AVCaptureMetadataOutput = AVCaptureMetadataOutput()
    
    //预览图层
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.session)
        return layer!
    }()
    
    var qrCodeFrameView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        preferredStatusBarStyle = UIStatusBarStyle.LightContent
        
        qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView)

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        //扫描
        startScan()
    }
    
    private func startScan(){
        
        if !session.canAddInput(deviceInput)
        {
            return
        }
        
        if !session.canAddOutput(output)
        {
            return
        }
        
        session.addInput(deviceInput)
        session.addOutput(output)
        
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        previewLayer.frame = UIScreen.main.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
        
        session.startRunning()
    }
    
    @IBAction func BackAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
 
    
    @IBAction func openAbum(_ sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            
            let picker = UIImagePickerController()
            
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            picker.allowsEditing = true
            
            self.present(picker, animated: true, completion: { 
                
            })
        }
        else
            {
                print("读取相册错误")
            }
            
            
        
        
    }
    
    
   
}


extension ScanCodeController: AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let ciImage:CIImage=CIImage(image: image)!
        
        let context = CIContext(options: nil)
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context,
                                  options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
        
        let features = detector?.features(in: ciImage)
        
        
        picker.dismiss(animated: true) {
            if features?.count == 0 {
                self.showMessage("未检测到二维码")
            }else{
                let feature = features![0] as! CIQRCodeFeature
                self.makeDeviceAdd(with: feature.messageString!)
            }
        }
        
    }
    
    
    //扫描代理方法：只要解析到数据就会调用
     func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!)
    {
        print(metadataObjects)
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
//            qrCodeFrameView?.frame = CGRectZero
//            messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject =
                previewLayer.transformedMetadataObject(for: metadataObj
                    as AVMetadataMachineReadableCodeObject) as!
            AVMetadataMachineReadableCodeObject
            qrCodeFrameView.frame = barCodeObject.bounds;
            
            if metadataObj.stringValue != nil {
                self.makeDeviceAdd(with: metadataObj.stringValue)
                self.session.stopRunning()
            }else{
                self.showMessage("未检测到二维码")
            }
        }
    }
    
    
    func showMessage(_ text: String) {
        let vc = UIAlertController.init(title: "提示", message: text, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        vc.addAction(action)
        self.present(vc, animated: true) { 
            
        }
    }

    
    func makeDeviceAdd(with infoStr:String) {
        
        var info = DeviceBindInfo()
        info.isMaster = false
        
//                根据二维码信息判断二维码类型
        //app 分享
        do {
            if let json = try JSONSerialization.jsonObject(with: infoStr.utf8Encoded, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] {
                print(json)

                if let embeded = json["embeded"] as? [String: Any], let _ = json["links"] as? [String: Any] {
                    
//                    判断二维码是否过期
                    if let expired = embeded["expired_at"] as? Int {
                        let now = Int(Date().timeIntervalSince1970)
                        if now > expired {
                            self.showMessage("二维码已过期")
                        }
                    }
                    
                    info.deviceId = embeded["imei"] as? String
                    info.phone = embeded["phone"] as? String
                    let str = embeded["identity"] as? String
                    if let identity = NumberFormatter().number(from: str!)?.intValue {
                        info.identity = Relation(rawValue: identity)
                    }
                }
            }
        } catch {
            print(infoStr)
        }
        
//        手表显示
        if infoStr.characters.count == 19 {
            let index = infoStr.index(infoStr.endIndex, offsetBy: -4)
            info.deviceId = infoStr.substring(to: index)
        }
        
        self.checkImeiAndGoBind(with: info)
    }
    
    
    func checkImeiAndGoBind(with info: DeviceBindInfo) {
        
        if info.phone == nil
            || info.phone?.characters.count  == 0
            || info.identity == nil {
            let vc = R.storyboard.main.phoneNumberController()!
            vc.deviceAddInfo = info
            self.navigationController?.show(vc, sender: nil)
        }else{
            _ = DeviceManager.shared.checkBind(deviceId: info.deviceId!).subscribe({ (event) in
                switch event{
                case .next(let value):
                    if value == false {
                        _ = DeviceManager.shared.joinGroup(joinInfo: info).subscribe({ (event) in
                            switch event{
                            case .next(let value):
                                print(value)
                            case .completed:
                                _ = self.navigationController?.popToRootViewController(animated: true)
                            case .error(let error):
                                print(error)
                                self.showMessage(error.localizedDescription)
                            }
                        })
                    }
                case .error(let error):
                    print(error)
                    self.showMessage("The watch has been paired by others,please contact this watch's master to share QR code with you.")
                default:
                    break
                }
            })
        }

    }
 
    
    
    
    
}











