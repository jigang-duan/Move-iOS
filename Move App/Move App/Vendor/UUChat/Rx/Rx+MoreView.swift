//
//  Rx+MoreView.swift
//  Move App
//
//  Created by jiang.duan on 2017/4/17.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


extension Reactive where Base: MoreView {
    
    /// Reactive wrapper for `delegate`.
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    var delegate: DelegateProxy {
        return RxMoreViewDelegateProxy.proxyForObject(base)
    }
    
    var clearAll: ControlEvent<Void> {
        let source = delegate
            .methodInvoked(#selector(MoreViewDelegate.clearAll))
            .map { _ in Void() }
        return ControlEvent(events: source)
    }
    
    var delete: ControlEvent<[Int]> {
        let source = delegate
            .methodInvoked(#selector(MoreViewDelegate.delete))
            .map {
                return try castOrThrow([Int].self, $0[1])
            }
        return ControlEvent(events: source)
    }
}

class RxMoreViewDelegateProxy
    : DelegateProxy
    , DelegateProxyType
, MoreViewDelegate {
    
    /// For more information take a look at `DelegateProxyType`.
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let moreView: MoreView = castOrFatalError(object)
        moreView.delegate = castOptionalOrFatalError(delegate)
    }
    
    /// For more information take a look at `DelegateProxyType`.
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let moreView: MoreView = castOrFatalError(object)
        return moreView.delegate
    }
}

fileprivate func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    
    return returnValue
}
