//
//  FamilyMemberViewModel.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class FamilyMemberViewModel {
    
    var cellDatas: Observable<[FamilyMemberCellData]>?
    
    let selected: Driver<FamilyMemberDetailController.ContactDetailInfo>
    
    var contacts: [FamilyMemberDetailController.ContactDetailInfo]?
    
    init (input: (
        enterCount: Observable<Int>,
        selectedContact: Driver<FamilyMemberDetailController.ContactDetailInfo>
        ),
          dependency: (
        deviceManager: DeviceManager,
        wireframe: Wireframe
        )
        ) {
        
        let deviceManager = dependency.deviceManager
        let _ = dependency.wireframe
        
        let enter = input.enterCount.filter({ $0 > 0 })
        
        self.selected = input.selectedContact
        
        
        self.cellDatas = enter.flatMapLatest({ _ in
            deviceManager.getContacts(deviceId: (deviceManager.currentDevice?.deviceId)!).map{ members in
                var cellDatas: [FamilyMemberCellData] = []
                var cons: [FamilyMemberDetailController.ContactDetailInfo] = []
                
                for mb in members {
                    var memberState = [FamilyMemberCellState.other]
                   
                    if UserInfo.shared.id == mb.uid {
                        memberState = [.me]
                    }
                    if mb.admin == true {
                        memberState = [.master]
                        if UserInfo.shared.id == mb.uid {
                            memberState = [.master, .me]
                        }
                    }
                    
                    let cellData = FamilyMemberCellData(headUrl: mb.profile ?? "", isHeartOn: self.transformIsHeartOn(flag: mb.flag ?? 0), relation: (mb.identity?.description) ?? "", state: memberState)
                    cellDatas.append(cellData)
                    
                    let conInfo = FamilyMemberDetailController.ContactDetailInfo(contactInfo: mb, isMaster: memberState.contains(.master), isMe: memberState.contains(.me))
                    cons.append(conInfo)
                }
                
                self.contacts = cons
                
                return cellDatas
            }
        })
    }
    
    
    func transformIsHeartOn(flag: Int) -> Bool {
        return flag == flag | 0x0100
    }
    
    
}




