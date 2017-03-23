//
//  MoveApi+Device.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/2/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import ObjectMapper
import Moya
import RxSwift
import Moya_ObjectMapper

extension MoveApi {
    
    class Device: NSObject {
        
        var versionInfo: DeviceVersionInfo?
        var currentParsedElementValue:String! //当前解析的元素中的值
        
        var version: Version?
        var firmware: Firmware?
        
        var isVersion = false
        var isReleaseInfo = false
        var isfirmware = false
        var isFileset = false
        var isFile = false
        var isSpoplist = false
        var isSpopnb = false
  
        var tempFile: VersionFile?
        
        
        static let defaultProvider = OnlineProvider<API>(
            endpointClosure: MoveApi.Device.endpointMapping,
            plugins: [
                MoveAccessTokenPlugin(),
                NetworkLoggerPlugin(verbose: true, output: Logger.reversedLog)
            ])
        
        final class func request(_ target: API) -> Observable<Response> {
            return defaultProvider.request(target)
        }
//        检查设备绑定状态
        final class func checkBind(deviceId: String) ->Observable<DeviceBind>{
            return request(.checkBind(deviceId: deviceId)).mapMoveObject(DeviceBind.self)
        }
//        添加设备
        final class func add(deviceId: String, addInfo: DeviceAdd) -> Observable<ApiError> {
            return request(.add(deviceId: deviceId, addInfo: addInfo)).mapMoveObject(ApiError.self)
        }
//        加入设备群组
        final class func joinDeviceGroup(deviceId: String, joinInfo: DeviceContactInfo) ->Observable<ApiError>{
            return request(.joinDeviceGroup(deviceId: deviceId, joinInfo: joinInfo)).mapMoveObject(ApiError.self)
        }
//        获取设备列表
        final class func getDeviceList(pid: Int = 0) -> Observable<DeviceGetListResp> {
            return request(.getDeviceList(pid: pid)).mapMoveObject(DeviceGetListResp.self)
        }
//        获取设备信息
        final class func getDeviceInfo(deviceId: String) -> Observable<DeviceInfo> {
            return request(.getDeviceInfo(deviceId: deviceId)).mapMoveObject(DeviceInfo.self)
        }
//        修改设备信息
        final class func update(deviceId: String, updateInfo: DeviceUpdateReq) -> Observable<ApiError> {
            return request(.update(deviceId: deviceId, updateInfo: updateInfo)).mapMoveObject(ApiError.self)
        }
//        删除设备
        final class func delete(deviceId: String) -> Observable<ApiError> {
            return request(.delete(deviceId: deviceId)).mapMoveObject(ApiError.self)
        }
//        添加设备联系人:  添加非注册用户为设备联系人，仅管理员调用
        final class func addNoRegisterMember(deviceId: String) -> Observable<ApiError> {
            return request(.addNoRegisterMember(deviceId: deviceId)).mapMoveObject(ApiError.self)
        }
//        删除设备联系人:  解绑设备的绑定成员，仅设备管理员调用
        final class func deleteBindUser(deviceId: String, uid: String) -> Observable<ApiError> {
            return request(.deleteBindUser(deviceId: deviceId, uid: uid)).mapMoveObject(ApiError.self)
        }
//        获取设备联系人
        final class func getContacts(deviceId: String) -> Observable<DeviceContacts> {
            return request(.getContacts(deviceId: deviceId)).mapMoveObject(DeviceContacts.self)
        }
//        设置联系人信息:  由管理员或联系人自己调用
        final class func settingContactInfo(deviceId: String, info: DeviceContactInfo, uid: String) -> Observable<ApiError> {
            return request(.settingContactInfo(deviceId: deviceId, info: info, uid: uid)).mapMoveObject(ApiError.self)
        }
//        设置设备管理员:  由管理员自身调用
        final class func settingAdmin(deviceId: String, admin: DeviceAdmin) -> Observable<ApiError> {
            return request(.settingAdmin(deviceId: deviceId, admin: admin)).mapMoveObject(ApiError.self)
        }
//        获取设备好友列表: 由管理员自身调用
        final class func getWatchFriends(deviceId: String) -> Observable<DeviceFriends> {
            return request(.getWatchFriends(deviceId: deviceId) ).mapMoveObject(DeviceFriends.self)
        }
//        删除设备好友:   由管理员自身调用
        final class func deleteWatchFriend(deviceId: String, uid: String) -> Observable<ApiError> {
            return request(.deleteWatchFriend(deviceId: deviceId, uid: uid)).mapMoveObject(ApiError.self)
        }
//        查看设备配置
        final class func getSetting(deviceId: String) -> Observable<DeviceSetting> {
            return request(.getSetting(deviceId: deviceId)).mapMoveObject(DeviceSetting.self)
        }
//        设置设备配置
        final class func setting(deviceId: String, settingInfo: DeviceSetting) -> Observable<ApiError> {
            return request(.setting(deviceId: deviceId, settingInfo: settingInfo)).mapMoveObject(ApiError.self)
        }
//        查看设备属性
        final class func getProperty(deviceId: String) -> Observable<DeviceProperty> {
            return request(.getProperty(deviceId: deviceId)).mapMoveObject(DeviceProperty.self)
        }
//        设置设备属性
        final class func settingProperty(deviceId: String, settingInfo: DeviceProperty) -> Observable<ApiError> {
            return request(.settingProperty(deviceId: deviceId, settingInfo: settingInfo)).mapMoveObject(ApiError.self)
        }
//        发送提醒
        final class func sendNotify(deviceId: String, sendInfo: DeviceSendNotify) -> Observable<ApiError>{
            return request(.sendNotify(deviceId: deviceId, sendInfo: sendInfo)).mapMoveObject(ApiError.self)
        }
//        上报电量
        final class func addPower(deviceId: String, power: DevicePower) -> Observable<ApiError> {
            return request(.addPower(deviceId: deviceId, power: power)).mapMoveObject(ApiError.self)
        }
//        获取电量
        final class func getPower(deviceId: String) -> Observable<DevicePower> {
            return request(.getPower(deviceId: deviceId)).mapMoveObject(DevicePower.self)
        }
        
//        检查watch新版本信息
        final func checkVersion(checkInfo: DeviceVersionCheck) -> Observable<DeviceVersionInfo> {
            return MoveApi.Device.request(.checkVersion(checkInfo: checkInfo)).map(transformXml)
        }
        
        enum API {
            case checkBind(deviceId: String)
            case add(deviceId: String, addInfo: DeviceAdd)
            case joinDeviceGroup(deviceId: String, joinInfo: DeviceContactInfo)
            case getDeviceList(pid: Int)
            case getDeviceInfo(deviceId: String)
            case update(deviceId: String, updateInfo: DeviceUpdateReq)
            case delete(deviceId: String)
            case addNoRegisterMember(deviceId: String)
            case deleteBindUser(deviceId: String, uid: String)
            case getContacts(deviceId: String)
            case settingContactInfo(deviceId: String, info: DeviceContactInfo, uid: String)
            case settingAdmin(deviceId: String, admin: DeviceAdmin)
            case getWatchFriends(deviceId: String)
            case deleteWatchFriend(deviceId: String, uid: String)
            case getSetting(deviceId: String)
            case setting(deviceId: String, settingInfo: DeviceSetting)
            case getProperty(deviceId: String)
            case settingProperty(deviceId: String, settingInfo: DeviceProperty)
            case sendNotify(deviceId: String, sendInfo: DeviceSendNotify)
            case addPower(deviceId: String, power: DevicePower)
            case getPower(deviceId: String)
            case checkVersion(checkInfo: DeviceVersionCheck)
        }
        
        
        final func transformXml(with response:Response) -> DeviceVersionInfo {
            versionInfo = DeviceVersionInfo()
            let xmlParse = XMLParser(data: response.data)
            
            xmlParse.delegate = self
            xmlParse.parse()
            
            return self.versionInfo!
        }
        
    }
}


extension MoveApi.Device: XMLParserDelegate {

    //解析XML文档结束
    func parserDidEndDocument(_ parser: XMLParser) {
//        print(versionInfo ?? MoveApi.DeviceVersionInfo())
    }
    
    //开始解析每个XML每个元素之前,即解析开始标签元素,如开始标签<news>
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        switch elementName {
        case "VERSION":
            versionInfo?.version = MoveApi.Version()
            isVersion = true
        case "RELEASE_INFO":
            versionInfo?.version?.releaseInfo = MoveApi.ReleaseInfo()
            isReleaseInfo = true
        case "FIRMWARE":
            versionInfo?.firmware = MoveApi.Firmware()
            isfirmware = true
        case "FILESET":
            versionInfo?.firmware?.fileset = []
            isFileset = true
        case "FILE":
            isFile = true
            tempFile = MoveApi.VersionFile()
        case "SPOP_LIST":
            isSpoplist = true
            versionInfo?.spopList = []
        case "SPOP_NB":
            isSpopnb = true
        default:
            break
        }
        
    }
    
    //解析每个XML元素之后，即解析结束标签元素,如闭合标签</news>
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        
        if !isVersion && !isReleaseInfo && !isfirmware && !isFileset && !isFile && !isSpoplist {
            
            switch elementName {
            case "UPDATE_DESC":
                versionInfo?.update_desc = currentParsedElementValue
            case "ENCODING_ERROR":
                versionInfo?.encoding_error = currentParsedElementValue
            case "CUREF":
                versionInfo?.curef = currentParsedElementValue
            default:
                break
            }
            
        }
        
        
        if isVersion == true {
            
            switch elementName {
            case "TYPE":
                versionInfo?.version?.type = currentParsedElementValue
            case "FV":
                versionInfo?.version?.fv = currentParsedElementValue
            case "TV":
                versionInfo?.version?.tv = currentParsedElementValue
            case "SVN":
                versionInfo?.version?.svn = currentParsedElementValue
            case "RELEASE_INFO":
                isReleaseInfo = false
            case "VERSION":
                isVersion = false
            default:
                break
            }
            
            if isReleaseInfo == true {
                switch elementName {
                case "year":
                    versionInfo?.version?.releaseInfo?.year = currentParsedElementValue
                case "month":
                    versionInfo?.version?.releaseInfo?.month = currentParsedElementValue
                case "day":
                    versionInfo?.version?.releaseInfo?.day = currentParsedElementValue
                case "hour":
                    versionInfo?.version?.releaseInfo?.hour = currentParsedElementValue
                case "minute":
                    versionInfo?.version?.releaseInfo?.minute = currentParsedElementValue
                case "second":
                    versionInfo?.version?.releaseInfo?.second = currentParsedElementValue
                case "timezone":
                    versionInfo?.version?.releaseInfo?.timezone = currentParsedElementValue
                case "publisher":
                    versionInfo?.version?.releaseInfo?.publisher = currentParsedElementValue
                case "RELEASE_INFO":
                    isReleaseInfo = false
                default:
                    break
                }
            }
            
        }
        
        if isfirmware == true {
            
            switch elementName {
            case "FW_ID":
                versionInfo?.firmware?.fwId = currentParsedElementValue
            case "FILESET_COUNT":
                versionInfo?.firmware?.filesetCount = currentParsedElementValue
            case "FIRMWARE":
                isfirmware = false
            default:
                break
            }
            
            if isFileset == true {
                switch elementName {
                case "FILESET":
                    isFileset = false
                default:
                    break
                }
                
                if isFile == true {
                    
                    switch elementName {
                    case "FILENAME":
                        tempFile?.fileName = currentParsedElementValue
                    case "FILE_ID":
                        tempFile?.fileId = currentParsedElementValue
                    case "SIZE":
                        tempFile?.size = currentParsedElementValue
                    case "CHECKSUM":
                        tempFile?.checkSum = currentParsedElementValue
                    case "FILE_VERSION":
                        tempFile?.fileVersion = currentParsedElementValue
                    case "INDEX":
                        tempFile?.index = currentParsedElementValue
                    case "FILE":
                        isFile = false
                        versionInfo?.firmware?.fileset?.append(tempFile!)
                    default:
                        break
                    }
                }
            }
        }
        
        if isSpoplist == true {
            
            switch elementName {
            case "SPOP_LIST":
                isSpoplist = false
            default:
                break
            }
            
            if isSpopnb == true {
                switch elementName {
                case "SPOP_NB":
                    isSpopnb = false
                    versionInfo?.spopList?.append(currentParsedElementValue!)
                default:
                    break
                }
            }
        }
        
    }
    
    //解析XML的内容
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        //替换字符串：去掉换行
        let str = string.trimmingCharacters(in: CharacterSet.newlines)
        self.currentParsedElementValue = str
    }

}



extension MoveApi.Device.API: AccessTokenAuthorizable {
    var shouldAuthorize: Bool {
        if case MoveApi.Device.API.checkVersion(_) = self {
            return false
        }else{
            return true
        }
    }
}

extension MoveApi.Device.API: TargetType {
    
    /// The target's base `URL`.
    var baseURL: URL {
        if case MoveApi.Device.API.checkVersion(_) = self {
            return URL(string: "http://g2master-sa-east.tctmobile.com")!
        }else{
            return URL(string: MoveApi.BaseURL)!
        }
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .checkBind(let deviceId):
            return "/v1.0/device/\(deviceId)/bind"
        case .add(let deviceId, _):
            return "/v1.1/device/\(deviceId)"
        case .joinDeviceGroup(let deviceId, _):
            return "/v1.0/device/\(deviceId)/join"
        case .getDeviceList:
            return "/v1.1/device/devices"
        case .getDeviceInfo(let deviceId):
            return "/v1.1/device/\(deviceId)"
        case .update(let deviceId, _):
            return "/v1.1/device/\(deviceId)"
        case .delete(let deviceId):
            return "/v1.0/device/\(deviceId)"
        case .addNoRegisterMember(let deviceId):
            return "/v1.0/device/\(deviceId)/contact"
        case .deleteBindUser(let deviceId, let uid):
            return "/v1.0/device/\(deviceId)/contact/\(uid)"
        case .getContacts(let deviceId):
            return "/v1.0/device/\(deviceId)/contacts"
        case .settingContactInfo(let deviceId, _, let uid):
            return "/v1.0/device/\(deviceId)/contact/\(uid)"
        case .settingAdmin(let deviceId, _):
            return "/v1.0/device/\(deviceId)/admin"
        case .getWatchFriends(let deviceId):
            return "/v1.0/device/\(deviceId)/friends"
        case .deleteWatchFriend(let deviceId, let uid):
            return "/v1.0/device/\(deviceId)/friend/\(uid)"
        case .getSetting(let deviceId):
            return "/v1.0/device/\(deviceId)/settings"
        case .setting(let deviceId, _):
            return "/v1.0/device/\(deviceId)/settings"
        case .getProperty(let deviceId):
            return "/v1.0/device/\(deviceId)/properties"
        case .settingProperty(let deviceId, _):
            return "/v1.0/device/\(deviceId)/properties"
        case .sendNotify(let deviceId, _):
            return "/\(deviceId)/notify"
        case .addPower(let deviceId, _):
            return "/v1.0/device/\(deviceId)/power"
        case .getPower(let deviceId):
            return "/v1.0/device/\(deviceId)/power"
        case .checkVersion:
            return "check.php"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .add, .joinDeviceGroup, .sendNotify, .addNoRegisterMember:
            return .post
        case .checkBind, .getDeviceList, .getDeviceInfo, .getContacts, .getSetting, .getProperty, .getPower, .getWatchFriends, .checkVersion:
            return .get
        case .update, .setting, .settingContactInfo, .settingProperty, .addPower, .settingAdmin:
            return .put
        case .delete, .deleteBindUser, .deleteWatchFriend:
            return .delete
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case .add(_, let addInfo):
            return addInfo.toJSON()
        case .joinDeviceGroup(_, let joinInfo):
            return joinInfo.toJSON()
        case .checkBind, .getDeviceList, .getDeviceInfo, .delete, .addNoRegisterMember, .deleteBindUser, .getContacts, .getSetting, .getProperty, .getPower, .getWatchFriends, .deleteWatchFriend:
            return nil
        case .update(_, let updateInfo):
            return updateInfo.toJSON()
        case .setting(_, let settingInfo):
            return settingInfo.toJSON()
        case .settingContactInfo(_, let info, _):
            return info.toJSON()
        case .settingAdmin(_, let admin):
            return admin.toJSON()
        case .settingProperty(_, let settingInfo):
            return settingInfo.toJSON()
        case .sendNotify(_, let sendInfo):
            return sendInfo.toJSON()
        case .addPower(_, let power):
            return power.toJSON()
        case .checkVersion(let checkInfo):
            return checkInfo.toJSON()
        }
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding {
        if case MoveApi.Device.API.checkVersion = self {
            return URLEncoding.queryString
        }else{
            return JSONEncoding.default
        }
    }
    
    /// Provides stub data for use in testing.
    var sampleData: Data {
        switch self {
        case .getDeviceList:
            return ([MoveApi.DeviceInfo()].toJSONString()?.utf8Encoded)!
        case .getDeviceInfo:
            return (MoveApi.DeviceInfo().toJSONString()?.utf8Encoded)!
        case .getSetting:
            return (MoveApi.DeviceSetting().toJSONString()?.utf8Encoded)!
        default:
            return "{\"error_id\": 0, \"error_msg\":\"ok\"}".utf8Encoded
        }
    }
    
    /// The type of HTTP task to be performed.
    var task: Task { return .request }
    
}

extension MoveApi.Device {
    
    final class func endpointMapping(for target: API) -> Endpoint<API> {
        let endpoint = MoyaProvider.defaultEndpointMapping(for: target)
        switch target {
        case .getDeviceList(let pid):
            return endpoint.adding(newHTTPHeaderFields: [
                "Accept": "application/json",
                "Content-Type": "application/json",
                "Accept-Language": Locale.preferredLanguages[0],
                "Authorization": "pid=\(pid);\(MoveApi.apiKey)"])
        default:
            return endpoint.adding(newHTTPHeaderFields: [
                "Accept": "application/json",
                "Content-Type": "application/json",
                "Accept-Language": Locale.preferredLanguages[0],
                "Authorization": MoveApi.apiKey])
        }
    }
}
