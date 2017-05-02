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
                //管理员不能取消紧急联系人身份
                if con.admin == true {
                    let res = Driver.just(ValidationResult.empty)
                    return Driver.just(res)
                }
                if flag {
                    //最多设置4个紧急联系人
                    if cons.map({self.transformIsHeartOn(flag: $0.contactInfo?.flag ?? 0)}).filter({$0 == true}).count >= 4 {
                        let res = Driver.just(ValidationResult.empty)
                        return Driver.just(res)
                    }
                    con.flag = self.setEmergency(flag: con.flag!)
                }else{
                    con.flag = self.clearEmergency(flag: con.flag!)
                }
                return Driver.just(deviceManager.settingContactInfo(contactInfo: con)
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
                
                let ms = self.sortedContacts(members)
                
                var cellDatas: [FamilyMemberCellData] = []
                var cons: [FamilyMemberDetailController.ContactDetailInfo] = []
                var isNowMaster = false
                
                for mb in ms {
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
    
    
    func sortedContacts(_ cons: [ImContact]) -> [ImContact] {
        //根据identity排序
        let ms = cons.sorted(by: { (c1, c2) -> Bool in
            (c1.identity?.description)! < (c2.identity?.description)!
        })
        //找出自己放到最前
        var arr: [ImContact] = ms
        var meIndex = 0
        var me: ImContact?
       
        for i in 0..<ms.count {
            let m = ms[i]
            if m.uid == UserInfo.shared.id {
                meIndex = i
                me = m
            }
        }
        arr.remove(at: meIndex)
        arr.insert(me!, at: 0)
        //找出master放到最前
        var arr1 = arr
        var masterIndex = 0
        var master: ImContact?
        for i in 0..<arr.count {
            let m = arr[i]
            if m.admin == true {
                masterIndex = i
                master = m
            }
        }
        arr1.remove(at: masterIndex)
        arr1.insert(master!, at: 0)
        
        return arr1
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




