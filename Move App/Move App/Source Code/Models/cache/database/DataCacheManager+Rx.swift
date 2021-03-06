//
//  DataCacheManager.swift
//  Move App
//
//  Created by jiang.duan on 2017/7/28.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift

class DataCacheObserver<E>: ObserverType {
    
    var manager: DataCacheManager?
    
    let binding: (DataCacheManager, E) -> Void
    
    init(manager: DataCacheManager = DataCacheManager.shared, binding: @escaping (DataCacheManager, E) -> Void) {
        self.manager = manager
        self.binding = binding
    }
    
    /**
     Binds next element
     */
    func on(_ event: Event<E>) {
        switch event {
        case .next(let element):
            if let manager = manager {
                binding(manager, element)
            }
        case .error:
            manager = nil
        case .completed:
            manager = nil
        }
    }
    
    /**
     Erases the type of observer
     
     - returns: AnyObserver, type erased observer
     */
    func asObserver() -> AnyObserver<E> {
        return AnyObserver(eventHandler: on)
    }
    
    deinit {
        manager = nil
    }
}

extension DataCacheManager: ReactiveCompatible { }

extension Reactive where Base: DataCacheManager {
    
    func get(key: String) -> Observable<String> {
        let ticker = self.base.get(key: key)
        return Observable.collection(from: ticker).map{ $0.first?.value }.filterNil()
    }
    
    func get(key: String, default value: String) -> Observable<String> {
        return self.get(key: key).startWith(value)
    }
    
    func getBool(key: String) -> Observable<Bool> {
        return self.get(key: key).map{ Bool($0) }.filterNil()
    }
    
    func getBool(key: String, default value: Bool) -> Observable<Bool> {
        return self.getBool(key: key).startWith(value)
    }
    
    func set() -> AnyObserver<(String, String)> {
        return DataCacheObserver(binding: { (dataCacheManager, element) in
            dataCacheManager.set(key: element.0, value: element.1)
        }).asObserver()
    }
    
    func set(key: String) -> AnyObserver<String> {
        return DataCacheObserver(binding: { (dataCacheManager, element) in
            dataCacheManager.set(key: key, value: element)
        }).asObserver()
    }
    
    func setBool() -> AnyObserver<(String, Bool)> {
        return DataCacheObserver(binding: { (dataCacheManager, element) in
            dataCacheManager.set(key: element.0, value: element.1)
        }).asObserver()
    }
    
    func setBool(key: String) -> AnyObserver<Bool> {
        return DataCacheObserver(binding: { (dataCacheManager, element) in
            dataCacheManager.set(key: key, value: element)
        }).asObserver()
    }
    
}
