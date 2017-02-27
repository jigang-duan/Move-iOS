//
//  Rx+WeekView.swift
//  Move App
//
//  Created by jiang.duan on 2017/2/24.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit
    
public class RxWeekViewDelegateProxy
    : DelegateProxy
    , DelegateProxyType
, WeekViewDelegate {
    
    /// For more information take a look at `DelegateProxyType`.
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let view: WeekView = castOrFatalError(object)
        view.delegate = castOptionalOrFatalError(delegate)
    }
    
    /// For more information take a look at `DelegateProxyType`.
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let view: WeekView = castOrFatalError(object)
        return view.delegate
    }
}

extension Reactive where Base: WeekView {
    
    /// Reactive wrapper for `delegate`.
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    var delegate: DelegateProxy {
        return RxWeekViewDelegateProxy.proxyForObject(base)
    }
    
    var weekSelected: ControlEvent<[Bool]> {
        let source = delegate
            .methodInvoked(#selector(WeekViewDelegate.weekViewDidSelected(_:selecteds:)))
            .map {
                return try castOrThrow([Bool].self, $0[1])
        }
        return ControlEvent(events: source)
    }
    
    /// Bindable sink for `week` property.
    var week: UIBindingObserver<Base, [Bool]> {
        return UIBindingObserver(UIElement: self.base) { week, sels in
            week.weekSelected = sels
        }
    }
}

fileprivate func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    
    return returnValue
}