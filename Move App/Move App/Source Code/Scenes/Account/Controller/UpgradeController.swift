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
    
    
    var viewModel: UpgradeViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let device = DeviceManager.shared.currentDevice!
        
        let placeImg = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: headImgV.frame.width, height: headImgV.frame.height), fullName: device.user?.nickname ?? "").imageRepresentation()!
        headImgV.imageFromURL(device.user?.profile ?? "", placeholder: placeImg)
        nameLab.text = device.user?.nickname ?? ""
        
        batteryLevel.text = "\(device.property?.power ?? 0)%"
        versionLab.text = device.property?.firmware_version
        
        
        viewModel = UpgradeViewModel(
            input: (
                downloadBun.rx.tap.asDriver()
            ),
            dependency:(
                deviceManager: DeviceManager.shared
            )
        )
        

    }
    
    
    
}
