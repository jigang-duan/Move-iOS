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
    func switchDid(cell: SafezoneCell, model: KidSate.ElectronicFencea)
}

class SafezoneCell: UITableViewCell {
    
    var delegate: SafezoneCellDelegate?
    
    @IBOutlet weak var switchOnOffQutiet: SwitchButton!
    @IBOutlet weak var addrLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    var disposeBag = DisposeBag()
    var model: KidSate.ElectronicFencea? = nil {
        didSet {
            nameLabel.text = model?.name
            addrLabel.text = model?.location?.address
            switchOnOffQutiet.isOn = model?.active ?? false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        switchOnOffQutiet.closureSwitch = { [unowned self] isOn in
            if let model = self.model {
                
                var vmodel = model
                vmodel.active = isOn
                self.delegate?.switchDid(cell: self, model: vmodel)
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
