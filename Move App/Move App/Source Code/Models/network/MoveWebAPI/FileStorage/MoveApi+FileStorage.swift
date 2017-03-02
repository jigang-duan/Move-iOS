//
//  MoveApi+FileStorage.swift
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
    
    class FileStorage {
        static let defaultProvider = OnlineProvider<API>(
            endpointClosure: MoveApi.FileStorage.endpointMapping,
            plugins: [
                MoveAccessTokenPlugin(),
                NetworkLoggerPlugin(verbose: true, output: Logger.reversedLog)
            ])
        
        final class func upload(fileInfo: FileInfo) -> Observable<FileUploadResp> {
            return defaultProvider.request(.upload(fileInfo: fileInfo)).mapMoveObject(FileUploadResp.self)
//                var uploadResp = FileUploadResp()
//                print($0.response?.request ?? "request", $0.response?.response ?? "response")
//                uploadResp.progress = $0.progress
//                if uploadResp.progress == 1{
//                    uploadResp.fid = try! $0.response?.mapString(atKeyPath: "fid")
//                }
//                return uploadResp
//            }
        }
        
        final class func download(fid: String) -> Observable<FileStorageInfo> {
            return defaultProvider.requestWithProgress(.download(fid: fid)).map{
                
                var fileStorageInfo = FileStorageInfo()
                fileStorageInfo.progressObject = $0.progressObject
                
                if $0.response != nil{
                    let res = $0.response
                    if (res?.statusCode)! >= 200 && (res?.statusCode)! < 400{
                        fileStorageInfo.progress = $0.progress
                        fileStorageInfo.name = $0.response?.response?.suggestedFilename
                        fileStorageInfo.type = $0.response?.response?.mimeType
                        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        fileStorageInfo.path = documentsURL.appendingPathComponent("DownloadFiles/\(fileStorageInfo.name)")
                        fileStorageInfo.fid = fid
                        
                    }else{
                        guard let json = try? res?.mapJSON() else {
                            throw MoyaError.jsonMapping(res!)
                        }
                        
                        if let apiError = Mapper<MoveApi.ApiError>().map(JSONObject: json),let errId = apiError.id, errId != 0 {
                            throw apiError
                        }
                    }
                }
                
                return fileStorageInfo
            }
        }
        
        final class func delete(fid: String) -> Observable<ApiError> {
            return defaultProvider.request(.delete(fid: fid)).mapMoveObject(ApiError.self)
        }
        
        enum API {
            case upload(fileInfo: FileInfo)
            case download(fid: String)
            case delete(fid: String)
        }
        
    }
}

extension MoveApi.FileStorage.API: AccessTokenAuthorizable {
    var shouldAuthorize: Bool {
        return true
    }
}

extension MoveApi.FileStorage.API: TargetType {
    
    /// The target's base `URL`.
    var baseURL: URL {
        return URL(string: MoveApi.BaseURL + "/v1.0")!
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .upload(let fileInfo):
            return "fs?type=\(fileInfo.type ?? "")&duration=\(fileInfo.duration ?? 0)"
        case .download(let fid):
            return "fs/\(fid)"
        case .delete(let fid):
            return "fs/\(fid)"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .upload:
            return .post
        case .download:
            return .get
        case .delete:
            return .delete
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        return nil
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding { return JSONEncoding.default }
    
    /// Provides stub data for use in testing.
    var sampleData: Data {
        switch self {
        case .upload:
            return "{\"error_id\": 0, \"error_msg\":\"ok\"}".utf8Encoded
        case .download:
            return "{\"error_id\": 0, \"error_msg\":\"ok\"}".utf8Encoded
        case .delete:
            return "{\"error_id\": 0, \"error_msg\":\"ok\"}".utf8Encoded
        }
    }
    
    /// The type of HTTP task to be performed.
    var task: Task {
        switch self {
        case .upload(let fileInfo):
            return .upload(UploadType.multipart([MultipartFormData(provider: MultipartFormData.FormDataProvider.data(fileInfo.data!), name: "file", mimeType: fileInfo.type)]))
        case .download:
            return .download(DownloadType.request({ (_, response) in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent("DownloadFiles/\(response.suggestedFilename!)")
                //两个参数表示如果有同名文件则会覆盖，如果路径中文件夹不存在则会自动创建
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }))
        case .delete:
            return .request
        }
    }
    
}

extension MoveApi.FileStorage {
    final class func endpointMapping(for target: API) -> Endpoint<API> {
        let endpoint = MoyaProvider.defaultEndpointMapping(for: target)
        return endpoint.adding(newHTTPHeaderFields: [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": MoveApi.apiKey])
    }
}
