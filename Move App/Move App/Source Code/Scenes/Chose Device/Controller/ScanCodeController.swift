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
    
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var albumBun: UIButton!
    @IBOutlet weak var tipLab: UILabel!
    @IBOutlet weak var imeiBun: UIButton!
    @IBOutlet weak var orLab: UILabel!
    
    var disposeBag = DisposeBag()
    
    var photoPicker: ImageUtility?
    
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
    
    private func initializeI18N() {
        self.title = R.string.localizable.id_qr_code()
        titleLab.text = R.string.localizable.id_qr_code()
        albumBun.setTitle(R.string.localizable.id_title_album(), for: .normal)
        tipLab.text = R.string.localizable.id_scan_hint()
        imeiBun.setTitle(R.string.localizable.id_input_imei(), for: .normal)
        orLab.text = R.string.localizable.id_or()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeI18N()

        qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView)
        
        //准备扫描
        prepareForScan()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        
        self.sessionRun()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        
        qrCodeFrameView.frame = CGRect()
        self.sessionStop()
    }
    
    
    
    func sessionRun(){
        if session.inputs.count > 0 {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    func sessionStop(){
        if session.inputs.count > 0 {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    
    private func prepareForScan(){
        
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
    }
    
    
    @IBAction func openAbum(_ sender: AnyObject) {
        photoPicker = ImageUtility()
        
        self.photoPicker?.selectPhoto(with: self, soureType: .photoLibrary, callback: { [weak self] (image) in
            let ciImage = CIImage(image: image)!
            
            let context = CIContext()
            let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context,
                                      options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
            
            let features = detector?.features(in: ciImage)
            
            if let fs = features, fs.count > 0 {
                let feature = fs[0] as! CIQRCodeFeature
                self?.makeDeviceAdd(with: feature.messageString!)
            }else{
                self?.showMessage(R.string.localizable.id_no_qr_code_detected())
            }
        })
    }
    
    @IBAction func backAction(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
   
}


extension ScanCodeController: AVCaptureMetadataOutputObjectsDelegate{
    
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
                self.sessionStop()
                self.makeDeviceAdd(with: metadataObj.stringValue)
            }else{
                self.showMessage(R.string.localizable.id_no_qr_code_detected())
            }
        }
    }
    
    
    func showMessage(_ text: String) {
        let vc = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: R.string.localizable.id_ok(), style: .cancel, handler: { _ in
            self.sessionRun()
        })
        vc.addAction(action)
        self.present(vc, animated: true)
    }

    
    func makeDeviceAdd(with infoStr:String) {
        
        var isValidQRcode = false
        
        var info = DeviceBindInfo()
        
//                根据二维码信息判断二维码类型
        //app 分享----普通用户加入
        do {
            if let json = try JSONSerialization.jsonObject(with: infoStr.utf8Encoded, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] {
                print(json)

                if let embeded = json["embeded"] as? [String: Any], let _ = json["links"] as? [String: Any] {
                    
//                    判断二维码是否过期
                    if let expired = embeded["expired_at"] as? Int {
                        let now = Int(Date().timeIntervalSince1970)
                        if now > expired {
                            self.showMessage(R.string.localizable.id_code_has_expired())
                        }else{
                            isValidQRcode = true
                            
                            info.isMaster = false
                            info.deviceId = embeded["imei"] as? String
                            info.phone = embeded["phone"] as? String
                            info.profile = embeded["profile"] as? String
                            info.owner_token = embeded["token"] as? String
                            if let str = embeded["identity"] as? String {
                                info.identity = Relation(input: str)
                            }
                            
                            self.checkImeiAndGoBind(with: info)
                        }
                    }
                }
            }
        } catch {
            print(infoStr)
        }
        
//        手表显示----管理员绑定
        if infoStr.characters.count == 19 {
            isValidQRcode = true
            
            let index = infoStr.index(infoStr.endIndex, offsetBy: -4)
            info.deviceId = infoStr.substring(to: index)
            info.isMaster = true
            
            self.checkImeiAndGoBind(with: info)
        }
        
        if isValidQRcode == false {
            self.showMessage(R.string.localizable.id_qr_code_invalid())
        }
        
    }
    
    
    func checkImeiAndGoBind(with info: DeviceBindInfo) {
        //绑定管理员
        if info.isMaster == true {
            DeviceManager.shared.checkBind(deviceId: info.deviceId!)
                .subscribe(onNext: { [weak self] flag in
                    if flag == false {
                        let vc  = R.storyboard.main.verificationCodeController()!
                        vc.imei = info.deviceId
                        self?.navigationController?.show(vc, sender: nil)
                    }else{
                        self?.showMessage(R.string.localizable.id_device_isbind())
                    }
                })
                .addDisposableTo(disposeBag)
            
            return
        }
        
        //绑定普通用户,先检查手表是否已存在
        DeviceManager.shared.getContacts(deviceId: info.deviceId!)
            .subscribe(onNext: { [weak self] cons in
                let flag = cons.map({$0.uid}).contains(where: { uid -> Bool in
                    return uid == UserInfo.shared.id
                })
                if flag == true {
                    self?.showMessage(R.string.localizable.id_watch_existed())
                }else{
                    self?.goPairWithGeneral(with: info)
                }
            }, onError: { [weak self] error in
                self?.goPairWithGeneral(with: info)
            })
            .addDisposableTo(disposeBag)
       
    }
    
    
    //去绑定普通用户
    func goPairWithGeneral(with info: DeviceBindInfo) {
        let vc = R.storyboard.main.phoneNumberController()!
        vc.deviceAddInfo = info
        self.navigationController?.show(vc, sender: nil)
    }
 
    
    
    
    
}











