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
            .drive(onNext: { [unowned self] valid, progress in
                self.downloadBun.isEnabled = valid
                self.downloadBun.tintColor?.withAlphaComponent(valid ? 1.0 : 0.5)
                self.makeDownloadBlur(progress: progress)
            })
            .addDisposableTo(disposeBag)
        
     
        
        viewModel.downResult
            .drive(onNext: { [unowned self] result in
                switch result {
                case .failed(let message):
                    self.showMessage(message)
                case .ok:
                    MessageServer.share.progressDownload?.subscribe(
                        onNext: { info in
                            print(info.content ?? "")
                        }, onError: { (er) in
                            print(er)
                        }).addDisposableTo(self.disposeBag)
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    
    func makeDownloadBlur(progress: Int) {
        if downloadBlur == nil{
            downloadBlur = UIView()
            downloadBlur?.backgroundColor = UIColor(argb: 0x88ffffff)
        }
        self.tipLab.isHidden = false
        
        if progress > 0 && progress < 100 {
            if !self.downloadBun.subviews.contains(downloadBlur!) {
                self.downloadBun.addSubview(downloadBlur!)
            }
            let maxLength = downloadBun.frame.size.width
            downloadBlur?.frame = CGRect(x: 0, y: 0, width: CGFloat(progress)/100*maxLength, height: self.downloadBun.frame.size.height)
        }else{
            if progress == 100 {
                self.fetchProperty()
            }
            downloadBlur?.removeFromSuperview()
        }
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
        let device = DeviceManager.shared.currentDevice!
        
        let propertyResult = DeviceManager.shared.getProperty(deviceId: device.deviceId!).flatMapLatest { property -> Observable<ValidationResult> in
            DeviceManager.shared.currentDevice?.property = property
            self.batteryLevel.text = "\(property.power ?? 0)%"
            self.batteryImgV.image = UIImage(named: "home_ic_battery\((property.power ?? 0)/20)")
            
            
            var checkInfo = DeviceVersionCheck(deviceId: device.deviceId, mode: "2", cktp: "2", curef: property.device_model, cltp: "10", type: "Firmware", fv: "")
            var ff = ""
            if let fv = property.firmware_version {
                if fv.characters.count > 2 {
                    ff = fv.substring(from: fv.index(fv.startIndex, offsetBy: fv.characters.count - 2))
                }
            }
            checkInfo.fv = "MT30" + ff
            
            //TODO: for test
            checkInfo.fv = "MT3006"
            checkInfo.curef = "MTMSM8909W"
            
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
    
    
    
    func checkVersion(checkInfo: DeviceVersionCheck) -> Observable<ValidationResult> {
        let result = DeviceManager.shared.checkVersion(checkInfo: checkInfo).map{ info -> ValidationResult in
            if info.currentVersion == info.newVersion {
                self.versionLab.text = "Firmware Version " + (info.currentVersion ?? "")
                self.versionInfo.isHidden = false
                self.versionInfo.text = "This watch's firmware is up to date."
                self.tipLab.isHidden = true
                self.downloadBun.isHidden = true
            }else{
                self.versionLab.text = "New Firmware Version " + (info.newVersion ?? "")
                self.versionInfo.isHidden = true
                self.tipLab.isHidden = true
                self.downloadBun.isHidden = false
            }
            self.activity.stopAnimating()
            return ValidationResult.ok(message: "Download Begin")
        }
        
        
        result.subscribe(onNext: { result in
            switch result {
            case .failed(let message):
                self.showMessage(message)
            default:
                break
            }
        }).addDisposableTo(disposeBag)
        
        return result
    }
    
    
    
}
