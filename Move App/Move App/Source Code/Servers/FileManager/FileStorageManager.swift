//

//  FileStorageManager.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/18.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift

class FSManager {
    
    static let shared = FSManager()
    
}

extension FSManager {
    
    class func imageUrl(with profile: String) -> String {
        return  MoveApi.BaseURL + "/v1.0/fs/\(profile)"
    }
    
    
    func uploadPngImage(with image: UIImage) -> Observable<FileUpload> {
        return  MoveApi.FileStorage.upload(fileInfo: MoveApi.FileInfo(type: "image", duration: nil, data: UIImagePNGRepresentation(image), fileName: "image.png", mimeType: "image/png")).map({FileUpload(fid: $0.fid, progress: $0.progress)})
    }
    
    func uploadJpgImage(with image: UIImage) -> Observable<FileUpload> {
        return  MoveApi.FileStorage.upload(fileInfo: MoveApi.FileInfo(type: "image", duration: nil, data: UIImageJPEGRepresentation(image, 1), fileName: "image.jpg", mimeType: "image/jpeg")).map({FileUpload(fid: $0.fid, progress: $0.progress)})
    }

}




struct FileUpload {
    var fid: String?
    var progress: Double?
}

struct FileStorageInfo {
    var name: String?
    var type: String?
    var path: URL?
    var fid: String?
    var progress: Double?
    var progressObject: Progress?
}

protocol FileWorkerProtocl {
    func upload(fileInfo: MoveApi.FileInfo) -> Observable<MoveApi.FileUploadResp>
    func download(fid: String) -> Observable<MoveApi.FileStorageInfo>
}

class FileStorageManager  {
    static let share = FileStorageManager()
    
    fileprivate var worker: FileWorkerProtocl!
    
    init() {
        worker = MoveApiFileWorker()
    }
    
    func upload(fileInfo: MoveApi.FileInfo) -> Observable<MoveApi.FileUploadResp> {
        return worker.upload(fileInfo:fileInfo)
    }
    
    func download(fid: String) -> Observable<MoveApi.FileStorageInfo> {
        return worker.download(fid: fid)
    }
}
