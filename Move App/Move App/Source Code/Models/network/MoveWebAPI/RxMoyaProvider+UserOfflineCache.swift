//
//  RxMoyaProvider+UserOfflineCache.swift
//  Move App
//
//  Created by jiang.duan on 2017/6/13.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import AwesomeCache


extension RxMoyaProvider where Target: TargetType {

    func tryUseOfflineCacheThenRequest(token: Target) -> Observable<Moya.Response> {
        
        // Creates an observable that starts a request each time it's subscribed to.
        return Observable.create { observer in
            let key = token.cacheKey
            
            if let cacheResponse = UseOfflineCache.shared.cachedResponse(forKey: key) {
                observer.onNext(cacheResponse)
            }
            
            let cancellableToken = self.request(token) { result in
                switch result {
                case let .success(response):
                    observer.onNext(response)
                    observer.onCompleted()
                    
                    UseOfflineCache.shared.cachedResponse(response, forKey: key)
                    
                case let .failure(error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                cancellableToken.cancel()
            }
        }
        
    }

}


protocol UseCache {
    var useCache: Bool { get }
}

extension TargetType {
    
    fileprivate var cacheKey: String {
        let url = self.baseURL.appendingPathComponent(self.path)
        let request = URLRequest(url: url)
        let encoderequest = (try? URLEncoding.queryString.encode(request, with: self.parameters)) ?? request
        return encoderequest.url?.absoluteString ?? url.absoluteString
    }
}


class UseOfflineCache {
    
    private let cacheURLResponse = try! Cache<URLResponse>(name: "URLResponse")
    private let cacheStatusCode = try! Cache<NSNumber>(name: "statusCode")
    private let cacheData = try! Cache<NSData>(name: "date")
    
    static let shared = UseOfflineCache()
    
    func cachedResponse(forKey key: String) -> Moya.Response? {
        guard
            let urlRespone = cacheURLResponse.object(forKey: key),
            let statusCode = cacheStatusCode.object(forKey: key)?.intValue else { return nil }
        guard let data = cacheData.object(forKey: key).flatMap({ Data(referencing: $0) }) else { return nil }
        
        return Moya.Response(statusCode: statusCode, data: data, request: nil, response: urlRespone)
    }
    
    func cachedResponse(_ response: Moya.Response, forKey key: String) {
        guard response.statusCode == 200 else { return }
        guard let urlRespone = response.response else { return }
        cacheURLResponse.setObject(urlRespone, forKey: key)
        cacheStatusCode.setObject(NSNumber(value: response.statusCode), forKey: key)
        cacheData.setObject(NSData(data: response.data), forKey: key)
    }
    
    func clean() {
        cacheURLResponse.removeAllObjects()
        cacheStatusCode.removeAllObjects()
        cacheData.removeAllObjects()
    }
    
    func clean(containKeys key: String) {
        cacheURLResponse.removeObjects(containKey: key)
        cacheStatusCode.removeObjects(containKey: key)
        cacheData.removeObjects(containKey: key)
    }
}


extension ObservableType {
   func catchErrorEmpty()
        -> Observable<E> {
            return self.catchError{ _ in Observable.empty() }
    }
}


fileprivate extension Cache {
    
    private func cacheKey(contain path: String) -> [String] {
        let urls = try? FileManager().contentsOfDirectory(at: self.cacheDirectory, includingPropertiesForKeys: nil, options: [])
        return urls?.flatMap { $0.deletingPathExtension().lastPathComponent }.filter { $0.contains(path) } ?? []
    }
    
    func removeObjects(containKey key: String) {
        self.cacheKey(contain: key).forEach { [unowned self] (key) in
            self.removeObject(forKey: key)
        }
    }
    
}
