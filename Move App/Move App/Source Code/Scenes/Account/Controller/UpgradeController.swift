//
//  UpgradeController.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/8.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import CustomViews
import RxSwift
import RxCocoa

class UpgradeController: UIViewController {
    
    @IBOutlet weak var headImgV: UIImageView!
    @IBOutlet weak var nameLab: UILabel!
    @IBOutlet weak var batteryImgV: UIImageView!
    
    @IBOutlet weak var batteryLevel: UILabel!
    
    @IBOutlet weak var versionLab: UILabel!
    @IBOutlet weak var versionInfo: UILabel!
    
    @IBOutlet weak var tipLab: UILabel!
    @IBOutlet weak var downloadBun: UIButton!
    
    
    let activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    var viewModel: UpgradeViewModel!
    let disposeBag = DisposeBag()
    
    var enterCount = Variable(0)
    var downloadProgress = Variable(0)
    
    var downloadBlur: UIView?
    var progressLab: UILabel?
    
    private var lastProgress = 0

    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.setupUI()
        
        self.fetchProperty()
        
        viewModel = UpgradeViewModel(
            input: (
                enter: enterCount.asDriver(),
                downloadProgress: downloadProgress.asDriver(),
                downloadTaps: downloadBun.rx.tap.asDriver()
            ),
            dependency:(
                deviceManager: DeviceManager.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        
        viewModel.downEnabled
            .drive(onNext: { [unowned self] valid in
                self.updateDownloadButton(isEnable: valid)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.downResult
            .drive(onNext: { [unowned self] result in
                switch result {
                case .failed(let message):
                    self.showMessage(message)
                case .ok(let message):
                    print(message)
                    self.updateDownloadButton(isEnable: false)
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //放这里防止UI显示问题
        let devidUID = RxStore.shared.currentDevice.map({ $0.user?.uid }).filterNil()
        MessageServer.share.firmwareUpdate?
            .withLatestFrom(devidUID) { ($0, $1) }
            .filter({ $0.deviceUID == $1 })
            .map({ $0.0 })
            .subscribe(onNext: { type in
                self.updateDownloadStatus(with: type)
            })
            .addDisposableTo(disposeBag)
    }
    
    
    
    func updateDownloadStatus(with type: FirmwareUpdateType) {
        switch type {
        case .updateStarted:
            break
        case .updateSucceed:
            self.fetchProperty()
        case .updateDefeated:
            self.fetchProperty()
        case .downloadStarted:
            break
        case .downloadDefeated:
            self.fetchProperty()
        case .checkDefeated:
            self.fetchProperty()
        case .progressDownload:
            let progress = type.progress
            if lastProgress < progress {
                lastProgress = progress
                self.updateDownloadButton(isEnable: false)
                print("下载进度===\(progress)")
                self.downloadProgress.value = progress
                self.makeDownloadBlur(progress: self.downloadProgress.value)
                self.tipLab.isHidden = false
            }
        }
    }
    
    
    func makeDownloadBlur(progress: Int) {
        
        if downloadBlur == nil{
            downloadBlur = UIView()
            downloadBlur?.backgroundColor = UIColor(rgb: 0x0092EB)
            downloadBlur?.layer.cornerRadius = 5
            self.downloadBun.addSubview(downloadBlur!)
        }
        
        if progressLab == nil {
            progressLab = UILabel(frame: CGRect(x: 0, y: 0, width: self.downloadBun.frame.size.width, height: self.downloadBun.frame.size.height))
            progressLab?.textAlignment = .center
            progressLab?.font = UIFont.systemFont(ofSize: 15)
            progressLab?.textColor = UIColor.white
            self.downloadBun.addSubview(progressLab!)
        }
        
        
        if progress > 0 && progress < 100 {
            let maxLength = downloadBun.frame.size.width
            downloadBlur?.frame = CGRect(x: 0, y: 0, width: CGFloat(progress)/100*maxLength, height: self.downloadBun.frame.size.height)
            progressLab?.text = "Download:\(progress)%"
            downloadBun.setTitle("", for: .disabled)
        }else{
            downloadBlur?.removeFromSuperview()
            downloadBlur = nil
            progressLab?.removeFromSuperview()
            progressLab = nil
            
            if progress >= 100{
                self.updateDownloadButton(isEnable: false)
                downloadBun.setTitle("Download Finished", for: .disabled)
                self.downloadProgress.value = 0
            }
        }
    }
    
    
    func updateDownloadButton(isEnable: Bool) {
        self.downloadBun.isEnabled = isEnable
        self.downloadBun.backgroundColor = UIColor(argb: isEnable ? 0xFF0092EB:0x880092EB)
    }
    
    
    func showMessage(_ text: String) {
        let vc = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        vc.addAction(action)
        self.present(vc, animated: true)
    }
    
    func setupUI() {
        versionInfo.isHidden = true
        tipLab.isHidden = true
        downloadBun.isHidden = true
        
        let device = DeviceManager.shared.currentDevice!
        
        let placeImg = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: headImgV.frame.width, height: headImgV.frame.height), fullName: device.user?.nickname ?? "").imageRepresentation()!
        let imgUrl = URL(string: FSManager.imageUrl(with: device.user?.profile ?? ""))
        headImgV.kf.setImage(with: imgUrl, placeholder: placeImg)
        
        nameLab.text = device.user?.nickname ?? ""
        
        batteryLevel.text = "\(device.property?.power ?? 0)%"
        versionLab.text = "Firmware Version " + (device.property?.firmware_version ?? "")
        
        activity.center = self.view.center
        self.view.addSubview(activity)
        activity.startAnimating()
    }
    
    
    func fetchProperty() {
        let deviceId = RxStore.shared.currentDeviceId.value!
        
        DeviceManager.shared.getProperty(deviceId: deviceId)
            .subscribe(onNext: { property in
                RxStore.shared.bind(property: property)
                
                self.batteryLevel.text = "\(property.power ?? 0)%"
                self.batteryImgV.image = UIImage(named: "home_ic_battery\((property.power ?? 0)/20)")
                
                
                var checkInfo = DeviceVersionCheck(deviceId: deviceId, mode: "2", cktp: "2", curef: property.device_model, cltp: "10", type: "Firmware", fv: "")
                if let fv = property.firmware_version, fv.characters.count > 6 {
                    checkInfo.fv = fv.replacingCharacters(in:  Range(uncheckedBounds: (lower: fv.index(fv.startIndex, offsetBy: 4), upper: fv.index(fv.endIndex, offsetBy: -2))), with: "")
                }
                
                var type = FirmwareUpdateType.updateSucceed(deviceId)
                if let status = property.fota_sta {
                    if status >= 0 && status <= 100 {
                        type = .progressDownload(deviceId, status)
                    }else{
                        switch status {
                        case 101:
                            type = .updateStarted(deviceId)
                        case 102:
                            type = .updateSucceed(deviceId)
                        case 202:
                            type = .updateDefeated(deviceId)
                        case 200:
                            type = .downloadStarted(deviceId)
                        case 201:
                            type = .downloadDefeated(deviceId)
                        case 255:
                            type = .checkDefeated(deviceId)
                        default:
                            break
                        }
                    }
                }
                
                switch type {
                case .updateStarted, .downloadStarted, .progressDownload:
                    self.updateDownloadStatus(with: type)
                default:
                    self.checkVersion(checkInfo: checkInfo)
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    
    func checkVersion(checkInfo: DeviceVersionCheck) {
        DeviceManager.shared.checkVersion(checkInfo: checkInfo)
            .subscribe(onNext: { info in
                if let vs = info.newVersion, vs.characters.count > 2 {
                    self.versionLab.text = "New Firmware Version MT30_00_00.01_" + vs.substring(from: vs.index(vs.endIndex, offsetBy: -2))
                    self.versionInfo.isHidden = true
                    self.tipLab.isHidden = true
                    self.downloadBun.isHidden = false
                    self.updateDownloadButton(isEnable: true)
                }else{
                    let version = DeviceManager.shared.currentDevice?.property?.firmware_version
                    self.versionLab.text = "Firmware Version " + (version ?? "")
                    self.versionInfo.isHidden = false
                    self.versionInfo.text = "This watch's firmware is up to date."
                    self.tipLab.isHidden = true
                    self.downloadBun.isHidden = true
                }
                self.activity.stopAnimating()
            })
            .addDisposableTo(disposeBag)
    }
    
    
    
}
