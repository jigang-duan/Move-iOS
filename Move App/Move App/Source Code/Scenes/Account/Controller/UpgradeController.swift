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
    
    
    var needShowProgress = false//是否需要显示下载进度,下载操作可能非自己触发，或退出界面再进
    
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
        
     
        
        MessageServer.share.progressDownload?
            .subscribe(
                onNext: { info in
                    print("下载进度===\(info.content ?? "")")
                    self.downloadProgress.value = Int(info.content ?? "") ?? 0
                    self.makeDownloadBlur(progress: self.downloadProgress.value)
                    self.tipLab.isHidden = false
            }, onError: { (er) in
                print(er)
            }).addDisposableTo(self.disposeBag)
        
        viewModel.downResult
            .drive(onNext: { [unowned self] result in
                switch result {
                case .failed(let message):
                    self.showMessage(message)
                case .ok(let message):
                    print(message)
                    self.needShowProgress = true
                    self.updateDownloadButton(isEnable: false)
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    
    func makeDownloadBlur(progress: Int) {
        if needShowProgress == false {return}
        
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
            if progress >= 100{
                self.fetchProperty()
                self.needShowProgress = false
                self.downloadProgress.value = 0
            }
            downloadBlur?.removeFromSuperview()
            downloadBlur = nil
            progressLab?.removeFromSuperview()
            progressLab = nil
            downloadBun.setTitle("Download", for: .disabled)
            
        }
    }
    
    
    func updateDownloadButton(isEnable: Bool) {
        self.downloadBun.isEnabled = isEnable
        self.downloadBun.backgroundColor = UIColor(argb: isEnable ? 0xFF0092EB:0x880092EB)
    }
    
    
    func showMessage(_ text: String) {
        let vc = UIAlertController.init(title: "提示", message: text, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        vc.addAction(action)
        self.present(vc, animated: true) {
            
        }
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
        
        let propertyResult = DeviceManager.shared.getProperty(deviceId: deviceId).flatMapLatest { property -> Observable<ValidationResult> in
            self.updateProperty(property)
            self.batteryLevel.text = "\(property.power ?? 0)%"
            self.batteryImgV.image = UIImage(named: "home_ic_battery\((property.power ?? 0)/20)")
            
            
            var checkInfo = DeviceVersionCheck(deviceId: deviceId, mode: "2", cktp: "2", curef: property.device_model, cltp: "10", type: "Firmware", fv: "")
            if let fv = property.firmware_version, fv.characters.count > 6 {
                checkInfo.fv = fv.substring(with:  Range<String.Index>(uncheckedBounds: (lower: fv.index(fv.startIndex, offsetBy: 4), upper: fv.index(fv.endIndex, offsetBy: -2))))
            }
            
            return self.checkVersion(checkInfo: checkInfo)
        }
        
        propertyResult.subscribe(onNext: { result in
            switch result {
            case .failed(let message):
                self.showMessage(message)
            default:
                break
            }
        }).addDisposableTo(disposeBag)
    }
    
    func updateProperty(_ property: DeviceProperty) {
        var arr: [DeviceInfo] = []
        
        for info in RxStore.shared.deviceInfosState.value {
            var f = info
            if f.deviceId == RxStore.shared.currentDeviceId.value {
                f.property = property
            }
            arr.append(f)
        }
        RxStore.shared.deviceInfosState.value = arr
    }
    
    
    func checkVersion(checkInfo: DeviceVersionCheck) -> Observable<ValidationResult> {
        return DeviceManager.shared.checkVersion(checkInfo: checkInfo).map{ info -> ValidationResult in
            if let vs = info.newVersion {
                self.versionLab.text = "New Firmware Version " + vs
                self.versionInfo.isHidden = true
                self.tipLab.isHidden = true
                self.downloadBun.isHidden = false
                self.updateDownloadButton(isEnable: true)
            }else{
                var version = DeviceManager.shared.currentDevice?.property?.firmware_version
//                if let vs = version, vs.characters.count > 4 {
//                    version = vs.substring(from: vs.index(vs.endIndex, offsetBy: -4))
//                }
                self.versionLab.text = "Firmware Version " + (version ?? "")
                self.versionInfo.isHidden = false
                self.versionInfo.text = "This watch's firmware is up to date."
                self.tipLab.isHidden = true
                self.downloadBun.isHidden = true
                self.updateDownloadButton(isEnable: true)
            }
            self.activity.stopAnimating()
            return ValidationResult.ok(message: "Download Begin")
        }
    }
    
    
    
}
