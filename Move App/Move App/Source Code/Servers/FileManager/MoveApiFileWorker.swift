//
//  MoveApiFileWorker.swift
//  Move App
//
//  Created by yinxiao on 2017/3/18.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift

class MoveApiFileWorker: FileWorkerProtocl {
    
    func upload(fileInfo: MoveApi.FileInfo) -> Observable<MoveApi.FileUploadResp> {
        return MoveApi.FileStorage.upload(fileInfo:fileInfo)
    }
    
    func download(fid: String) -> Observable<MoveApi.FileStorageInfo> {
        return MoveApi.FileStorage.download(fid: fid)
    }

}
