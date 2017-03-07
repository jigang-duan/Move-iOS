//
//  Rx+SwitchButton.swift
//  LinkApp
//
//  Created by l x on 2017/2/13.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import CustomViews


extension Reactive where Base: SwitchButton {
    
    /// Reactive wrapper for `delegate`.
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    public var delegate: DelegateProxy {
        return RxSwitchButtonDelegateProxy.proxyForObject(base)
    }
    
    public var `switch`: ControlEvent<Bool> {
        let source = delegate
            .methodInvoked(#selector(SwitchButtonDelegate.didSwitch(_:on:)))
            .map {
                return try castOrThrow(Bool.self, $0[1])
        }
        return ControlEvent(events: source)
    }
    
    /// Bindable sink for `isOn` property.
    public var on: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { sw, on in
            sw.isOn = on
        }
    }
    
    public var value: ControlProperty<Bool> {
        return ControlProperty<Bool>(values: self.switch.asObservable(), valueSink: on)
    }
}


fileprivate func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    
    return returnValue
}
