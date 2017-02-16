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
        
        static let uploadProvider = RxMoyaProvider<API>(
            endpointClosure: MoveApi.FileStorage.uploadMapping,
            plugins: [
                MoveAccessTokenPlugin(),
                NetworkLoggerPlugin(verbose: true, output: Logger.reversedLog)
            ])
        
        static let downloadProvider = RxMoyaProvider<API>(
            endpointClosure: MoveApi.FileStorage.downloadMapping,
            plugins: [
                MoveAccessTokenPlugin(),
                NetworkLoggerPlugin(verbose: true, output: Logger.reversedLog)
            ])
        
        static let delteProvider = RxMoyaProvider<API>(
            endpointClosure: MoveApi.FileStorage.deleteMapping,
            plugins: [
                MoveAccessTokenPlugin(),
                NetworkLoggerPlugin(verbose: true, output: Logger.reversedLog)
            ])
        
        final class func upload(fileInfo: FileInfo) -> Observable<FileId> {
            return uploadProvider.request(.upload(fileInfo: fileInfo)).mapMoveObject(FileId.self)
        }
        
        final class func download(fid: String) -> Observable<FileInfo> {
            return downloadProvider.request(.download(fid: fid)).mapMoveObject(FileInfo.self)
        }
        
        final class func delete(fid: String) -> Observable<ApiError> {
            return delteProvider.request(.delete(fid: fid)).mapMoveObject(ApiError.self)
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
    var baseURL: URL { return URL(string: MoveApi.BaseURL + "/fs")! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .upload:
            return ""
        case .download(let fid):
            return "/\(fid)"
        case .delete(let fid):
            return "/\(fid)"
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
        switch self {
        case .upload(let fileInfo):
            return ["duration": fileInfo.duration ?? 0]
        case .download:
            return nil
        case .delete:
            return nil
        }
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
            return .upload(UploadType.multipart([MultipartFormData(provider: MultipartFormData.FormDataProvider.data(fileInfo.file!), name: "file", mimeType: fileInfo.type)]))
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
    
    final class func uploadMapping(for target: API) -> Endpoint<API> {
        let endpoint = MoyaProvider.defaultEndpointMapping(for: target)
        return endpoint.adding(newHTTPHeaderFields: [
            "Accept": "application/json",
            "Content-Type": "multipart/form-data",
            "Authorization": "key=\(MoveApi.apiKey)"])
    }
    
    final class func downloadMapping(for target: API) -> Endpoint<API> {
        let endpoint = MoyaProvider.defaultEndpointMapping(for: target)
        return endpoint.adding(newHTTPHeaderFields: [
            "Accept": "application/json",
            "Content-Type": "image/png",
            "Authorization": "key=\(MoveApi.apiKey)"])
    }
    
    final class func deleteMapping(for target: API) -> Endpoint<API> {
        let endpoint = MoyaProvider.defaultEndpointMapping(for: target)
        return endpoint.adding(newHTTPHeaderFields: [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "key=\(MoveApi.apiKey)"])
    }
}
