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

extension String {
    
    var fsImageUrl: String {
        return  MoveApi.BaseURL + "/v1.0/fs/\(self)"
    }
    
    var fsVoiceUrl: String {
        return  MoveApi.BaseURL + "/v1.0/fs/\(self)"
    }
    
}

extension FSManager {
    
    class func imageUrl(with profile: String) -> String {
        return  MoveApi.BaseURL + "/v1.0/fs/\(profile)"
    }
    
    
    func uploadPngImage(with image: UIImage) -> Observable<FileUpload> {
        return  MoveApi.FileStorage.upload(fileInfo: MoveApi.FileInfo(type: "image", duration: nil, data: UIImagePNGRepresentation(image), fileName: "image.png", mimeType: "image/png"))
            .map({FileUpload(fid: $0.fid, progress: $0.progress)})
    }
    
    func uploadJpgImage(with image: UIImage) -> Observable<FileUpload> {
        return  MoveApi.FileStorage.upload(fileInfo: MoveApi.FileInfo(type: "image", duration: nil, data: UIImageJPEGRepresentation(image, 1), fileName: "image.jpg", mimeType: "image/jpeg"))
            .map({FileUpload(fid: $0.fid, progress: $0.progress)})
    }
    
    func uploadVoice(with data: Data, duration time: Int) -> Observable<String> {
        return MoveApi.FileStorage.upload(fileInfo: MoveApi.FileInfo(type: "voice", duration: time, data: data, fileName: "voice.amr", mimeType: "voice/amr"))
            .map({FileUpload(fid: $0.fid, progress: $0.progress)})
            .map({ $0.fid })
            .filterNil()
            .takeLast(1)
    }
    
    
    
    func fetchVoice(fromURL url: URL, closure: @escaping (_ voiceData: Data?) -> ()) {
        // From Cache
        let path = url.path.components(separatedBy: "/").last
        let amrPath = NSTemporaryDirectory() + path! + "_tmp.amr"
        let amrURL = URL(fileURLWithPath: amrPath)
        let wavPath = NSTemporaryDirectory() + path! + "_tmp.wav"
        let wavURL = URL(fileURLWithPath: wavPath)
        if let cache = try? Data(contentsOf: wavURL) {
            closure(cache)
            return
        }
        
        data(fromURL: url) { data in
            guard let data = data else {
                closure(nil)
                return
            }
            
            do {
                try data.write(to: amrURL)
                
                if VoiceConverter.convertAmr(toWav: amrPath, wavSavePath: wavPath) == 1 {
                    if let cache = try? Data(contentsOf: wavURL) {
                        closure(cache)
                    }
                } else {
                    closure(nil)
                }
            } catch {
                closure(nil)
            }
            
        }
    }
    
    private func data(fromURL url: URL, closure: @escaping (_ data: Data?) -> ()) {
        
        // Fetch Data
        let session = URLSession(configuration: URLSessionConfiguration.default)
        var request = URLRequest(url: url)
        let auth = "\(MoveApi.apiKey);token=\(UserInfo.shared.accessToken.token)"
        request.setValue(auth, forHTTPHeaderField: "Authorization")
        session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                DispatchQueue.main.async {
                    closure(nil)
                }
            }
                
            if let data = data {
                DispatchQueue.main.async {
                    closure(data)
                }
            }
                session.finishTasksAndInvalidate()
        }).resume()
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
