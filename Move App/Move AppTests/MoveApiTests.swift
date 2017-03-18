//
//  MoveApiTests.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/7.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import XCTest
import RxTest
import RxBlocking
import Moya
@testable import Move_App

class MoveApiTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    //    Account
    func testAccountApi()  {
        let userInfo = ApiTestInfo.share.userInfo
        
        guard let registered = try? MoveApi.Account.isRegistered(account: userInfo.username!)
            .toBlocking()
            .last() else {
                
                XCTFail()
                return
        }
        XCTAssertEqual(registered?.isRegistered, true)
        
        
        //        if let _ = try? MoveApi.Account.register(userInfo: userInfo).do(onError: {
        //            Logger.error($0)
        //            guard let error = $0 as? MoveApi.ApiError else {
        //                XCTFail()
        //                return
        //            }
        //            XCTAssertEqual(error.id, 7)
        //            XCTAssertEqual(error.field, "username")
        //            XCTAssertEqual(error.msg, "Exists")
        //        }).toBlocking().last() {
        //            XCTFail()
        //        }
        
        let loginInfo = MoveApi.LoginInfo(username: userInfo.username, password: userInfo.password)
        guard let loginResp = try? MoveApi.Account.login(info: loginInfo)
            .toBlocking()
            .last() else {
                XCTFail()
                return
        }
        XCTAssertNotNil(loginResp)
        
        guard let refreshTokenResp = try? MoveApi.Account.refreshToken()
            .toBlocking()
            .last() else {
                XCTFail()
                return
        }
        XCTAssertNotNil(refreshTokenResp)
        
        
        guard let getUserInfoResp = try? MoveApi.Account.getUserInfo(uid: userInfo.uid!)
            .toBlocking()
            .last() else {
                XCTFail()
                return
        }
        XCTAssertNotNil(getUserInfoResp)
        
        
//        let userSetting = MoveApi.UserInfoSetting(phone: userInfo.phone, email: userInfo.email, profile: userInfo.profile, nickname: userInfo.nickname, password: userInfo.password, new_password: userInfo.password)
//        guard let settingUserInfoResp = try? MoveApi.Account.settingUserInfo(uid: userInfo.uid!, info: userSetting)
//            .toBlocking()
//            .last() else {
//                XCTFail()
//                return
//        }
//        XCTAssertEqual(settingUserInfoResp?.id, 0)
//        XCTAssertEqual(settingUserInfoResp?.msg, "ok")
        
        //        let findInfo = MoveApi.UserFindInfo(username: userInfo.username, email: userInfo.email, phone: userInfo.phone, password: userInfo.password)
        //        guard let findPasswordResp = try? MoveApi.Account.findPassword(info: findInfo)
        //            .toBlocking()
        //            .last() else {
        //                XCTFail()
        //                return
        //        }
        //        XCTAssertEqual(findPasswordResp?.id, 0)
        //        XCTAssertEqual(findPasswordResp?.msg, "ok")
        
        //                guard let logoutResp = try? MoveApi.Account.logout().toBlocking().last() else{
        //                    XCTFail()
        //                    return
        //                }
        //                XCTAssertEqual(logoutResp?.id, 0)
        //                XCTAssertEqual(logoutResp?.msg, "ok")
    }
    
    //    Verification
    func testVerificationApi()  {
        
        let testInfo = ApiTestInfo.share
        
        let loginInfo = MoveApi.LoginInfo(username: testInfo.userInfo.username, password: testInfo.userInfo.password)
        let _ = try? MoveApi.Account.login(info: loginInfo).toBlocking().last()
        
        guard let sid = try? MoveApi.VerificationCode.send(to: testInfo.userInfo.email!)
            .toBlocking()
            .last() else {
                XCTFail()
                return
        }
        XCTAssertNotNil(sid?.sid)
        testInfo.deviceAdd.sid = (sid?.sid)!
        
        let vcode = RandomString.sharedInstance.getRandomStringOfLength(length: 13)
        if let _ = try? MoveApi.VerificationCode.verify(sid: (sid?.sid)!, vcode: vcode).do(onError: {
            Logger.error($0)
            guard let error = $0 as? MoveApi.ApiError else {
                XCTFail()
                return
            }
            XCTAssertEqual(error.id, 5)
            XCTAssertEqual(error.field, "Invalid")
            XCTAssertEqual(error.msg, "vcode")
        }).toBlocking().last() {
            XCTFail()
        }
        
        guard let deleteResp = try? MoveApi.VerificationCode.delete(sid: (sid?.sid)!)
            .toBlocking()
            .last() else {
                XCTFail()
                return
        }
        XCTAssertEqual(deleteResp?.id, 0)
        XCTAssertEqual(deleteResp?.msg, "ok")
    }
    
    //    Device
    func testDeviceApi() {
        
//        let testInfo = ApiTestInfo.share
        
//        let loginInfo = MoveApi.LoginInfo(username: testInfo.userInfo.username, password: testInfo.userInfo.password)
//        let _ = try? MoveApi.Account.login(info: loginInfo).toBlocking().last()
        
//        let sidResp = try? MoveApi.VerificationCode.send(to: testInfo.userInfo.email!).toBlocking().last()
//        testInfo.deviceAdd.sid = (sidResp??.sid)!
        
//        if let _ = try? MoveApi.Device.add(deviceId: testInfo.deviceInfo.deviceId!, addInfo: testInfo.deviceAdd).do(onError: {
//            Logger.error($0)
//            guard let error = $0 as? MoveApi.ApiError else {
//                XCTFail()
//                return
//            }
//            XCTAssertEqual(error.id, 11)
//            XCTAssertEqual(error.field, "Access Token Invalid")
//            XCTAssertEqual(error.msg, "access_token")
//        }).toBlocking().last() {
//            XCTFail()
//        }
        //        加入设备群组
//        guard let joinDeviceGroupResp = try? MoveApi.Device.joinDeviceGroup(deviceId: testInfo.deviceInfo.deviceId!, joinInfo: MoveApi.DeviceJoinInfo(phone: testInfo.userInfo.phone, identity: MoveApi.DeviceAddIdentity.brother, profile: "")).toBlocking().last() else{
//            XCTFail()
//            return
//        }
//        XCTAssertEqual(joinDeviceGroupResp?.id, 0)
//        XCTAssertEqual(joinDeviceGroupResp?.msg, "ok")
        //        获取设备列表
//        guard let getDeviceListResp = try? MoveApi.Device.getDeviceList().toBlocking().last() else{
//            XCTFail()
//            return
//        }
//        XCTAssertNotNil(getDeviceListResp)
//        
//        
//        guard let getDeviceInfoResp = try? MoveApi.Device.getDeviceInfo(deviceId: testInfo.deviceInfo.deviceId!).toBlocking().last() else{
//            XCTFail()
//            return
//        }
//        XCTAssertNotNil(getDeviceInfoResp)
        //        修改设备信息
//        guard let updateResp = try? MoveApi.Device.update(deviceId: testInfo.deviceInfo.deviceId!, updateInfo: testInfo.deviceInfo).toBlocking().last() else{
//            XCTFail()
//            return
//        }
//        XCTAssertEqual(updateResp?.id, 0)
//        XCTAssertEqual(updateResp?.msg, "ok")
        //        删除设备
//        guard let deleteResp = try? MoveApi.Device.delete(deviceId: testInfo.deviceInfo.deviceId!).toBlocking().last() else{
//            XCTFail()
//            return
//        }
//        XCTAssertEqual(deleteResp?.id, 0)
//        XCTAssertEqual(deleteResp?.msg, "ok")
//        //        查看设备配置
//        guard let getSettingResp = try? MoveApi.Device.getSetting(deviceId: testInfo.deviceInfo.deviceId!).toBlocking().last() else{
//            XCTFail()
//            return
//        }
//        XCTAssertNotNil(getSettingResp)
//        testInfo.deviceSetting = getSettingResp!
//        //        设置设备配置
//        guard let settingResp = try? MoveApi.Device.setting(deviceId: testInfo.deviceInfo.deviceId!, settingInfo: testInfo.deviceSetting).toBlocking().last() else{
//            XCTFail()
//            return
//        }
//        XCTAssertEqual(settingResp?.id, 0)
//        XCTAssertEqual(settingResp?.msg, "ok")
//        
//        //        发送提醒
//        guard let sendNotifyResp = try? MoveApi.Device.sendNotify(deviceId: testInfo.deviceInfo.deviceId!, sendInfo: MoveApi.DeviceSendNotify(code: 101, value: "")).toBlocking().last() else{
//            XCTFail()
//            return
//        }
//        XCTAssertEqual(sendNotifyResp?.id, 0)
//        XCTAssertEqual(sendNotifyResp?.msg, "ok")
//        
//        
//        let power = MoveApi.DevicePower(power: 66)
//        //        上报电量
//        guard let addPowerResp = try? MoveApi.Device.addPower(deviceId: testInfo.deviceInfo.deviceId!, power: power).toBlocking().last() else{
//            XCTFail()
//            return
//        }
//        XCTAssertEqual(addPowerResp?.id, 0)
//        XCTAssertEqual(addPowerResp?.msg, "ok")
//        //        获取电量
//        guard let getPowerResp = try? MoveApi.Device.getPower(deviceId: testInfo.deviceInfo.deviceId!).toBlocking().last() else{
//            XCTFail()
//            return
//        }
//        XCTAssertEqual(getPowerResp?.power, power.power)
        
        let dv = MoveApi.Device()
        guard (try? dv.checkVersion(deviceId: "123456789102370").toBlocking().last()) != nil else{
            XCTFail()
            return
        }
    }
    
    //    ElectronicFence
    func testElectronicFenceApi() {
        
        let testInfo = ApiTestInfo.share
        
        let loginInfo = MoveApi.LoginInfo(username: testInfo.userInfo.username, password: testInfo.userInfo.password)
        let _ = try? MoveApi.Account.login(info: loginInfo).toBlocking().last()
        
        
//        guard let addFenceResp = try? MoveApi.ElectronicFence.addFence(deviceId: testInfo.deviceInfo.deviceId!, fenceReq: testInfo.fenceInfo).toBlocking().last() else{
//            XCTFail()
//            return
//        }
//        XCTAssertEqual(addFenceResp?.id, 0)
//        XCTAssertEqual(addFenceResp?.msg, "ok")
        
        
        guard let getFenceResp = try? MoveApi.ElectronicFence.getFences(deviceId: testInfo.deviceInfo.deviceId!).toBlocking().last() else{
            XCTFail()
            return
        }
        XCTAssertNotNil(getFenceResp)
        XCTAssertEqual(testInfo.fenceInfo.name, getFenceResp?.fences?[0].name)
    }
    
    //    FileStorage
    func testFileStorageApi(){
        let testInfo = ApiTestInfo.share
        
        let loginInfo = MoveApi.LoginInfo(username: testInfo.userInfo.username, password: testInfo.userInfo.password)
        let _ = try? MoveApi.Account.login(info: loginInfo).toBlocking().last()
        
        
//        guard let uploadResp = try? MoveApi.FileStorage.upload(fileInfo: testInfo.fileInfo).toBlocking().last() else{
//            XCTFail()
//            return
//        }
//        XCTAssertNotNil(uploadResp?.fid)
        
        guard let downloadResp = try? MoveApi.FileStorage.download(fid: "5,01b70efceab7")
            .debug()
            .do(onNext: { (downloadInfo) in
            print("下载进度=====\(downloadInfo.path)")
        }).toBlocking().last() else{
            XCTFail()
            return
        }
        XCTAssertNotNil(downloadResp)
        
//        guard let deleteResp = try? MoveApi.FileStorage.delete(fid: (uploadResp?.fid)!).toBlocking().last() else{
//            XCTFail()
//            return
//        }
//        XCTAssertEqual(deleteResp?.id, 0)
//        XCTAssertEqual(deleteResp?.msg, "ok")
        
    }
    
    //    Message
    func testHistoryMessageApi(){
        let testInfo = ApiTestInfo.share
        
        let loginInfo = MoveApi.LoginInfo(username: testInfo.userInfo.username, password: testInfo.userInfo.password)
        let _ = try? MoveApi.Account.login(info: loginInfo).toBlocking().last()
        
        //                查看聊天消息记录
        guard let getChatRecordResp = try? MoveApi.HistoryMessage.getChatRecord(uid: testInfo.userInfo.uid!, chatReq: testInfo.chatReq).toBlocking().last() else{
            XCTFail()
            return
        }
        XCTAssertNotNil(getChatRecordResp)
        //        设置消息已读状态
        guard let settingReadStatusResp = try? MoveApi.HistoryMessage.settingReadStatus(uid: testInfo.userInfo.uid!, msgid: RandomString.sharedInstance.getRandomStringOfLength(length: 10)) .toBlocking().last() else{
            XCTFail()
            return
        }
        XCTAssertEqual(settingReadStatusResp?.id, 0)
        XCTAssertEqual(settingReadStatusResp?.msg, "ok")
        //        删除聊天消息
        guard let deleteByMsgidResp = try? MoveApi.HistoryMessage.deleteByMsgid(uid: testInfo.userInfo.uid!, msgid: RandomString.sharedInstance.getRandomStringOfLength(length: 10)).toBlocking().last() else{
            XCTFail()
            return
        }
        XCTAssertEqual(deleteByMsgidResp?.id, 0)
        XCTAssertEqual(deleteByMsgidResp?.msg, "ok")
        //        清除聊天消息
        guard let cleanMessagesResp = try? MoveApi.HistoryMessage.cleanMessages(uid: testInfo.userInfo.uid!).toBlocking().last() else{
            XCTFail()
            return
        }
        XCTAssertEqual(cleanMessagesResp?.id, 0)
        XCTAssertEqual(cleanMessagesResp?.msg, "ok")
        
        //        查看通知消息记录
        guard let getNotificationsResp = try? MoveApi.HistoryMessage.getNotifications(uid: testInfo.userInfo.uid!, chatReq: testInfo.chatReq).toBlocking().last() else{
            XCTFail()
            return
        }
        XCTAssertNotNil(getNotificationsResp)
        
        //        设置通知已读状态
        guard let settingNotificationReadStatusResp = try? MoveApi.HistoryMessage.settingNotificationReadStatus(uid: testInfo.userInfo.uid!, msgid: RandomString.sharedInstance.getRandomStringOfLength(length: 10)) .toBlocking().last() else{
            XCTFail()
            return
        }
        XCTAssertEqual(settingNotificationReadStatusResp?.id, 0)
        XCTAssertEqual(settingNotificationReadStatusResp?.msg, "ok")
        //        删除通知消息
        guard let deleteNotificationResp = try? MoveApi.HistoryMessage.deleteNotification(uid: testInfo.userInfo.uid!, msgid: RandomString.sharedInstance.getRandomStringOfLength(length: 10)).toBlocking().last() else{
            XCTFail()
            return
        }
        XCTAssertEqual(deleteNotificationResp?.id, 0)
        XCTAssertEqual(deleteNotificationResp?.msg, "ok")
    }
    
    //    Location
    func testLocationApi() {
        
        let testInfo = ApiTestInfo.share
        
        let loginInfo = MoveApi.LoginInfo(username: testInfo.userInfo.username, password: testInfo.userInfo.password)
        let _ = try? MoveApi.Account.login(info: loginInfo).toBlocking().last()
        
        
        guard let addResp = try? MoveApi.Location.add(deviceId: testInfo.deviceInfo.deviceId!, locationAdd: testInfo.locationAdd).toBlocking().last() else{
            XCTFail()
            return
        }
        XCTAssertEqual(addResp?.id, 0)
        XCTAssertEqual(addResp?.msg, "ok")
        
        
        guard let getNewResp = try? MoveApi.Location.getNew(deviceId: testInfo.deviceInfo.deviceId!).toBlocking().last() else{
            XCTFail()
            return
        }
        XCTAssertNotNil(getNewResp)
        
        guard let getHistoryResp = try? MoveApi.Location.getHistory(deviceId: testInfo.deviceInfo.deviceId!, locationReq: MoveApi.LocationReq(start: Date(timeIntervalSinceNow: -86400), end: Date())).toBlocking().last() else{
            XCTFail()
            return
        }
        XCTAssertNotNil(getHistoryResp)
    }
    
    //    ActivityRecord
    func  testActivityRecordApi() {
        
        let testInfo = ApiTestInfo.share
        
        let loginInfo = MoveApi.LoginInfo(username: testInfo.userInfo.username, password: testInfo.userInfo.password)
        let _ = try? MoveApi.Account.login(info: loginInfo).toBlocking().last()
        
        //        上报活动记录
        guard let addResp = try? MoveApi.ActivityRecord.addRecord(deviceId: testInfo.deviceInfo.deviceId!, activityList: [testInfo.activity]).toBlocking().last() else{
            XCTFail()
            return
        }
        XCTAssertEqual(addResp?.id, 0)
        XCTAssertEqual(addResp?.msg, "ok")
        
        //        获取活动记录
        guard let getRecordResp = try? MoveApi.ActivityRecord.getRecord(deviceId: testInfo.deviceInfo.deviceId!, recordReq: MoveApi.RecordReq(start_time: Date(timeIntervalSinceNow: -86400), end_time: Date(), page_token: "", page_size: 20)).toBlocking().last() else{
            XCTFail()
            return
        }
        XCTAssertNotNil(getRecordResp)
        //        批量获取用户步数
        guard let getContactListStepResp = try? MoveApi.ActivityRecord.getContactListStep(contactList: [testInfo.contact]).toBlocking().last() else{
            XCTFail()
            return
        }
        XCTAssertNotNil(getContactListStepResp)
        
        //        运动点赞
        guard let sportLikeResp = try? MoveApi.ActivityRecord.sportLike(uid: testInfo.userInfo.uid!).toBlocking().last() else{
            XCTFail()
            return
        }
        XCTAssertEqual(sportLikeResp?.id, 0)
        XCTAssertEqual(sportLikeResp?.msg, "ok")
        //        取消运动点赞
        guard let cancelSportLikeResp = try? MoveApi.ActivityRecord.cancelSportLike(uid: testInfo.userInfo.uid!).toBlocking().last() else{
            XCTFail()
            return
        }
        XCTAssertEqual(cancelSportLikeResp?.id, 0)
        XCTAssertEqual(cancelSportLikeResp?.msg, "ok")
        //        获取单个用户步数(统计)
        guard let getContactStepSumResp = try? MoveApi.ActivityRecord.getContactStepSum(uid: testInfo.userInfo.uid!, stepSumReq: MoveApi.StepSumReq(start_time: Date(timeIntervalSinceNow: -86400), end_time: Date(), by: "")).toBlocking().last() else{
            XCTFail()
            return
        }
        XCTAssertNotNil(getContactStepSumResp)
        //        批量获取用户分数
        guard let getContactListScoreResp = try? MoveApi.ActivityRecord.getContactListScore(contactList: [testInfo.contact]).toBlocking().last() else{
            XCTFail()
            return
        }
        XCTAssertNotNil(getContactListScoreResp)
        
        //        游戏点赞
        guard let gameLikeResp = try? MoveApi.ActivityRecord.gameLike(uid: testInfo.userInfo.uid!).toBlocking().last() else{
            XCTFail()
            return
        }
        XCTAssertEqual(gameLikeResp?.id, 0)
        XCTAssertEqual(gameLikeResp?.msg, "ok")
        //        取消游戏点赞
        guard let cancelGameLikeResp = try? MoveApi.ActivityRecord.cancelGameLike(uid: testInfo.userInfo.uid!).toBlocking().last() else{
            XCTFail()
            return
        }
        XCTAssertEqual(cancelGameLikeResp?.id, 0)
        XCTAssertEqual(cancelGameLikeResp?.msg, "ok")
    }
    
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

class ApiTestInfo {
    
    let userInfo = MoveApi.UserInfoMap(uid: "15610241104716362019", phone: "17683880501", email: "491339607@qq.com", profile: "", nickname: "xxxx", username: "test003", password: "test003", gender: "", height: 1, weight: 1, unit_value: 1, unit_weight_value: 1, orientation: 1, birthday: Date(), mtime: Date())
    
    
    var deviceAdd = MoveApi.DeviceAdd(sid: "", vcode: "", phone: "", identity: "10", nickname: "", number: "", gender: "")
    var deviceInfo = MoveApi.DeviceInfo(pid: 513, deviceId: "device0001", user: nil, property: nil)
    
    var deviceSetting = MoveApi.DeviceSetting()
    
    
    var fenceInfo = MoveApi.FenceInfo(name: "fence001", location: MoveApi.Fencelocation(lat: 31.123456, lng: 121.123456, addr: "China"), radius: 1000, active: true)
    
    
    
    var fileInfo = MoveApi.FileInfo(type: "image", duration: nil, data: UIImagePNGRepresentation(R.image.phone_number()!), fileName: "image.png", mimeType: "image/png")
    
    var chatReq = MoveApi.GetChatReq(prev: "", next: "", count: 20)
    
    var locationAdd = MoveApi.LocationAdd()
    
    
    var activity = MoveApi.Activity()
    
    var contact = MoveApi.Contact()
    
    
    
    
    private init() {
        
    }
    static let share = ApiTestInfo()
}

/// 随机字符串生成
class RandomString {
    let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    
    /**
     生成随机字符串,
     
     - parameter length: 生成的字符串的长度
     
     - returns: 随机生成的字符串
     */
    func getRandomStringOfLength(length: Int) -> String {
        var ranStr = ""
        for _ in 0..<length {
            let index = Int(arc4random_uniform(UInt32(characters.characters.count)))
            ranStr.append(characters[characters.index(characters.startIndex, offsetBy: index)])
        }
        return ranStr
        
    }
    
    
    private init() {
        
    }
    static let sharedInstance = RandomString()
}
