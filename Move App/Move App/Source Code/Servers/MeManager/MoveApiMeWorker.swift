//
//  MoveApiMeWorker.swift
//  Move App
//
//  Created by jiang.duan on 2017/2/23.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift


class MoveApiMeWorker: MeWorkerProtocl {
    
    func checkRoles() -> Observable<[Role]> {
        return MoveApi.Device.getDeviceList().map(transformRoles)
    }
    
    
    func checkCurrentRole() -> Observable<Role?> {
        return self.checkRoles().map{ $0.first }
    }
    
    private func transformRole(form deviceInfo: MoveApi.DeviceInfo?) -> Role? {
        guard let device = deviceInfo,
            let id = deviceInfo?.device_id else {
            return nil
        }
        
        let kidProfile = KidProfile(kidId: id,
                                    phone: device.number,
                                    nickName: device.name,
                                    headPortrait: device.profile,
                                    gender: (device.gender == "male") ? .male : . female,
                                    height: device.height,
                                    weight: nil,
                                    birthday: device.birthday)
        let kid = Kid(id: id, profile: kidProfile)
        let guardian = Grardian()
        kid.relations.append(.unowner)
        guardian.kids.append((.unowner, kid))
        
        return guardian
    }
    
    private func transformRoles(form devices: [MoveApi.DeviceInfo]?) -> [Role] {
        guard let infos = devices else {
            return []
        }
        return infos.flatMap(transformRole)
    }
    
    private func transformRoles(form deviceGetListResp: MoveApi.DeviceGetListResp) -> [Role] {
        return self.transformRoles(form: deviceGetListResp.devices)
    }
    
}
