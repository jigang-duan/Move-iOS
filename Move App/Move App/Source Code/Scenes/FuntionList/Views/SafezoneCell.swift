//
//  SafezoneCell.swift
//  Move App
//
//  Created by LX on 2017/3/17.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import CustomViews
import RxSwift

protocol SafezoneCellDelegate {
    func switchDid(cell: SafezoneCell, model: KidSate.ElectronicFencea,autopositionBool: Bool,adminBool: Bool,vc: UIViewController,other1: Bool,other2: Bool,btn: SwitchButton)
}

class SafezoneCell: UITableViewCell {
    
    var delegate: SafezoneCellDelegate?
    
    @IBOutlet weak var switchOnOffQutiet: SwitchButton!
    @IBOutlet weak var addrLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var onOFFLabel: UILabel!
    var autopositioningBool: Bool? = false
    var adminBool: Bool? = false
    var autoAnswer: Bool?
    var savePower: Bool?
    var btn: SwitchButton?
    weak var vc: UIViewController?
    
    var disposeBag = DisposeBag()
    var model: KidSate.ElectronicFencea? = nil {
        didSet {
            nameLabel.text = model?.name
            addrLabel.text = model?.location?.address
            switchOnOffQutiet.isOn = model?.active ?? false
            if (model?.active)!{
                onOFFLabel.text = "On"
            }else
            {
                onOFFLabel.text = "Off"
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        switchOnOffQutiet.closureSwitch = { [unowned self] isOn in
            if let model = self.model {
                var vmodel = model
                let autopositionBool = self.autopositioningBool
                let admindBool = self.adminBool
                let vcc = self.vc
                let other11 = self.autoAnswer
                let other22 = self.savePower
                let btn = self.btn
                vmodel.active = isOn
                self.delegate?.switchDid(cell: self, model: vmodel, autopositionBool: autopositionBool!, adminBool: admindBool!, vc: vcc!, other1: other11!, other2: other22!, btn: btn!)
                
                if isOn{
                if admindBool! {
                    if !autopositionBool! {
                        let alertController = UIAlertController(title: "Warning", message: "Auto-positioning is closed,the location infromation is not timely, for more accurate location information, please open Auto-positioning, it will consume more power", preferredStyle: .alert)
                        
                        let notOpen = UIAlertAction(title: "Not open", style: .cancel, handler: nil)
                        
                        let open = UIAlertAction(title: "Open Auto-positionning", style: .default, handler: { (UIAlertAction) in
                            //发起请求打开open auto-positioning按钮
                           WatchSettingsManager.share.updateSavepowerAndautoAnswer(other11!, savepower: other22!, autoPosistion: true).subscribe({ (bool : Event<Bool>) in
    
                                    btn?.isOn = true
                            
                            }).addDisposableTo(self.disposeBag)
                            
                        })
                        alertController.addAction(notOpen)
                        alertController.addAction(open)
                        
                        vcc?.present(alertController, animated: true, completion: nil)
                    }
                }
                }

                 let fenceloc : MoveApi.Fencelocation = MoveApi.Fencelocation(lat: vmodel.location?.location?.latitude, lng: vmodel.location?.location?.longitude, addr: vmodel.location?.address)
                let fenceinfo : MoveApi.FenceInfo = MoveApi.FenceInfo(id: vmodel.ids, name: vmodel.name, location: fenceloc, radius: vmodel.radius, active: vmodel.active)
                let fencereq = MoveApi.FenceReq(fence : fenceinfo)
                
                MoveApi.ElectronicFence.settingFence(fenceId : (vmodel.ids)!, fenceReq: fencereq)
                    .subscribe(onNext: {
                        print($0)
                        if $0.msg != "ok" {
                            
                        }else{
                            
                        }
                    }).addDisposableTo(self.disposeBag)
                
            }
        }
    }
    
    
}
