//
//  ScanCodeController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/13.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import AVFoundation

class ScanCodeController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue(label: "main"))
        
        previewLayer.frame = UIScreen.main.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
        
        session.startRunning()
    }
    
    @IBAction func BackAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //会话
    private lazy var session: AVCaptureSession = AVCaptureSession()
    
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
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.session)
        return layer!
    }()
    
}
extension ScanCodeController: AVCaptureMetadataOutputObjectsDelegate{
    
    override var preferredStatusBarStyle: UIStatusBarStyle
        {
        return UIStatusBarStyle.lightContent
    }
    //扫描代理方法：只要解析到数据就会调用
     func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!)
    {
        print(metadataObjects)
    }
    

}
