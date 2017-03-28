//
//  Rx+UUInputView.swift
//  Move App
//
//  Created by jiang.duan on 2017/3/25.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


extension Reactive where Base: UUInputView {
    
    /// Reactive wrapper for `delegate`.
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    var delegate: DelegateProxy {
        return RxUUInputViewDelegateProxy.proxyForObject(base)
    }
    
    var sendEmoji: ControlEvent<String> {
        let source = delegate
            .methodInvoked(#selector(UUInputViewDelegate.UUInputView(_:sendEmoji:)))
            .map {
                return try castOrThrow(String.self, $0[1])
        }
        return ControlEvent(events: source)
    }
    
    var sendVoice: ControlEvent<(URL,Int)> {
        let source = delegate
            .methodInvoked(#selector(UUInputViewDelegate.UUInputView(_:sendURLForVoice:duration:)))
            .map {
                return (try castOrThrow(URL.self, $0[1]), try castOrThrow(Int.self, $0[2]))
        }
        return ControlEvent(events: source)
    }
}


class RxUUInputViewDelegateProxy
    : DelegateProxy
    , DelegateProxyType
, UUInputViewDelegate {
    
    /// For more information take a look at `DelegateProxyType`.
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let inputView: UUInputView = castOrFatalError(object)
        inputView.delegate = castOptionalOrFatalError(delegate)
    }
    
    /// For more information take a look at `DelegateProxyType`.
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let inputView: UUInputView = castOrFatalError(object)
        return inputView.delegate
    }
}


fileprivate func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    
    return returnValue
}
