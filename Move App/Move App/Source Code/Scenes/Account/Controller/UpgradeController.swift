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
    
    @IBOutlet weak var versionLab: UILabel!
    @IBOutlet weak var versionInfo: UILabel!
    
    @IBOutlet weak var tipLab: UILabel!
    @IBOutlet weak var downloadBun: UIButton!
    
    
    let activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    var viewModel: UpgradeViewModel!
    let disposeBag = DisposeBag()
    
    var enterCount = Variable(0)
    var downloadProgress = 0
    
    var downloadBlur: UIView?
    var progressLab: UILabel?

    
    private func initializeI18N() {
        self.title = R.string.localizable.id_update()
        
        tipLab.text = R.string.localizable.id_watch_fv_download_info()
        downloadBun.setTitle(R.string.localizable.id_download(), for: .normal)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.initializeI18N()
        
        self.setupUI()
        
        self.fetchProperty()
        
        viewModel = UpgradeViewModel(
            input: (
                enter: enterCount.asDriver(),
                downloadTaps: downloadBun.rx.tap.asDriver()
            ),
            dependency:(
                deviceManager: DeviceManager.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        
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
            .subscribe(onNext: { [weak self] type in
                self?.updateDownloadStatus(with: type)
            })
            .addDisposableTo(disposeBag)
    }
    
    
    
    func updateDownloadStatus(with type: FirmwareUpdateType) {
        switch type {
        case .updateStarted:
            self.updateDownloadStatus(with: .progressDownload("", 100))
        case .downloadStarted:
            self.updateDownloadStatus(with: .progressDownload("", 0))
        case .updateSucceed, .updateDefeated, .checkDefeated, .downloadDefeated:
            downloadProgress = 0
            self.fetchProperty()
        case .progressDownload:
            let progress = type.progress
            self.updateDownloadButton(isEnable: false)
            print("下载进度===\(progress)")
            downloadProgress = progress
            self.makeDownloadBlur(progress: progress)
            self.tipLab.isHidden = false
        default: ()
        }
    }
    
    
    func addDownloadBlur() {
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
    }
    
    
    func makeDownloadBlur(progress: Int) {
        if progress > 0 && progress < 100 {
            self.addDownloadBlur()
            
            let maxLength = downloadBun.frame.size.width
            downloadBlur?.frame = CGRect(x: 0, y: 0, width: CGFloat(progress)/100*maxLength, height: self.downloadBun.frame.size.height)
            progressLab?.text = R.string.localizable.id_download() + ":\(progress)%"
            downloadBun.setTitle("", for: .disabled)
        }else{
            downloadBlur?.removeFromSuperview()
            downloadBlur = nil
            progressLab?.removeFromSuperview()
            progressLab = nil
            
            if progress >= 100{
                self.updateDownloadButton(isEnable: false)
                downloadBun.setTitle(R.string.localizable.id_finished(), for: .disabled)
            }
        }
    }
    
    
    func updateDownloadButton(isEnable: Bool) {
        self.downloadBun.isEnabled = isEnable
        self.downloadBun.backgroundColor = UIColor(argb: isEnable ? 0xFF0092EB:0x880092EB)
    }
    
    
    func showMessage(_ text: String) {
        let vc = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: R.string.localizable.id_ok(), style: .cancel)
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
        
        versionLab.text = R.string.localizable.id_firmware_version() + " "  + (device.property?.firmware_version ?? "")
        
        activity.center = self.view.center
        self.view.addSubview(activity)
        activity.startAnimating()
    }
    
    
    func fetchProperty() {
        let deviceId = RxStore.shared.currentDeviceId.value!
        
        DeviceManager.shared.getProperty(deviceId: deviceId)
            .subscribe(onNext: { [weak self] property in
                RxStore.shared.bind(property: property)
                
                self?.batteryImgV.image = UIImage(named: "home_ic_battery\((property.power ?? 0)/10)")
                
                
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
                    self?.updateDownloadStatus(with: type)
                default:
                    break
                }
                self?.checkVersion(checkInfo: checkInfo)
            })
            .addDisposableTo(disposeBag)
    }
    
    
    func checkVersion(checkInfo: DeviceVersionCheck) {
        DeviceManager.shared.checkVersion(checkInfo: checkInfo)
            .subscribe(onNext: { [weak self] info in
                if let vs = info.newVersion, vs.characters.count > 2 {
                    self?.versionLab.text = R.string.localizable.id_new_firmware_version() + " " + "MT30_00_00.01_" + vs.substring(from: vs.index(vs.endIndex, offsetBy: -2))
                    self?.versionInfo.isHidden = true
                    self?.downloadBun.isHidden = false
                    if self?.downloadProgress == 0 {
                        self?.tipLab.isHidden = true
                        self?.updateDownloadButton(isEnable: true)
                        self?.downloadBun.setTitle(R.string.localizable.id_download(), for: .normal)
                    }
                }else{
                    let version = DeviceManager.shared.currentDevice?.property?.firmware_version
                    self?.versionLab.text = R.string.localizable.id_firmware_version() + " "  + (version ?? "")
                    self?.versionInfo.isHidden = false
                    self?.versionInfo.text = R.string.localizable.id_firmware_up_to_date()
                    self?.tipLab.isHidden = true
                    self?.downloadBun.isHidden = true
                }
                self?.activity.stopAnimating()
            })
            .addDisposableTo(disposeBag)
    }
    
    
    
}
