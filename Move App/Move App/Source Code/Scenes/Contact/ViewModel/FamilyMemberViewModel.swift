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
    var cellDatasVariable: Variable<[FamilyMemberCellData]> = Variable([])
    
    let selected: Driver<FamilyMemberDetailController.ContactDetailInfo>
    
    var contacts: [FamilyMemberDetailController.ContactDetailInfo]?
    
    var heartResult: Driver<Driver<ValidationResult>>?
    
    init (input: (
        enterCount: Observable<Int>,
        selectedContact: Driver<FamilyMemberDetailController.ContactDetailInfo>,
        cellHeartClick: Variable<(flag: Bool, row: Int)>
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
        
        
        
        heartResult = input.cellHeartClick.asDriver().flatMapLatest({ (flag, row) in
            if let cons = self.contacts {
                var con = (cons[row].contactInfo)!
                if flag {
                    con.flag = self.setEmergency(flag: con.flag!)
                }else{
                    con.flag = self.clearEmergency(flag: con.flag!)
                }
                return Driver.just(deviceManager.settingContactInfo(deviceId: (deviceManager.currentDevice?.deviceId)!, contactInfo: con)
                    .map({ _ in
                        self.contacts?[row].contactInfo?.flag = con.flag
                        self.cellDatasVariable.value[row].isHeartOn = self.transformIsHeartOn(flag: con.flag!)
                        return ValidationResult.ok(message: "Set Success.")
                    }).asDriver(onErrorRecover: commonErrorRecover))
            }else{
                let res = Driver.just(ValidationResult.empty)
                return Driver.just(res)
            }
        })
        
        self.cellDatas = enter.flatMapLatest({ _ in
            deviceManager.getContacts(deviceId: (deviceManager.currentDevice?.deviceId)!).map{ members in
                var cellDatas: [FamilyMemberCellData] = []
                var cons: [FamilyMemberDetailController.ContactDetailInfo] = []
                var isNowMaster = false
                
                for mb in members {
                    var memberState = [FamilyMemberCellState.other]
                   
                    if UserInfo.shared.id == mb.uid {
                        memberState = [.me]
                    }
                    if mb.admin == true {
                        memberState = [.master]
                        if UserInfo.shared.id == mb.uid {
                            memberState = [.master, .me]
                            isNowMaster = true
                        }
                    }
                    
                    let cellData = FamilyMemberCellData(headUrl: mb.profile ?? "", isHeartOn: self.transformIsHeartOn(flag: mb.flag ?? 0), relation: (mb.identity?.description) ?? "", state: memberState)
                    cellDatas.append(cellData)
                    
                    var conInfo = FamilyMemberDetailController.ContactDetailInfo()
                    conInfo.contactInfo = mb
                    conInfo.isMe = memberState.contains(.me)
                    cons.append(conInfo)
                }
                
                let cs = cons.map({con -> (FamilyMemberDetailController.ContactDetailInfo) in
                    var c = con
                    c.isNowMaster = isNowMaster
                    return c
                })
                
                self.contacts = cs
                
                return cellDatas
            }
        })
    }
    
    
    func transformIsHeartOn(flag: Int) -> Bool {
        return flag == flag | 0x0100
    }
    
    
    func setEmergency(flag: Int) -> Int {
        return flag | 0x0100
    }
    
    func clearEmergency(flag: Int) -> Int {
        return Int(UInt(flag) & ~UInt(0x0100))
    }
}




