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
        imManager: IMManager,
        deviceManager: DeviceManager,
        wireframe: Wireframe
        )
        ) {
        
        let imManager = dependency.imManager
        let deviceManager = dependency.deviceManager
        let _ = dependency.wireframe
        
        let enter = input.enterCount.filter({ $0 > 0 })
        
        self.selected = input.selectedContact
        
        
        self.cellDatas = enter.flatMapLatest({ _ in
            imManager.getGroups().map{ groups in
                var cellDatas: [FamilyMemberCellData] = []
                var cons: [FamilyMemberDetailController.ContactDetailInfo] = []
                for info in groups {
                    for mb in info.members! {
                        if deviceManager.currentDevice?.user?.uid == mb.uid {
                           break
                        }
                    }
                    for mb in info.members! {
                        var cellData = FamilyMemberCellData(headUrl: mb.profile, isHeartOn: mb.flag == 1 ? true:false, relation: mb.identity ?? "", isOwner: mb.uid == info.owner ? true:false, isMe: false)
                        if UserInfo.shared.id == mb.uid {
                            cellData.isMe = true
                        }
                        cellDatas.append(cellData)
                        let conInfo = FamilyMemberDetailController.ContactDetailInfo(contactInfo: mb, isMaster: cellData.isOwner, isMe: cellData.isMe)
                        cons.append(conInfo)
                    }
                    self.contacts = cons
                }
                return cellDatas
            }
        })
        
    }
    
    
}






