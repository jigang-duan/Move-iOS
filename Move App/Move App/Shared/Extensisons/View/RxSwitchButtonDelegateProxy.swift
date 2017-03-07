//
//  RxSwitchButtonDelegateProxy.swift
//  LinkApp
//
//  Created by l x on 2017/2/13.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

#if os(iOS)
    
    import Foundation
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif
    import UIKit
    import CustomViews
    
    public class RxSwitchButtonDelegateProxy
        : DelegateProxy
        , DelegateProxyType
    , SwitchButtonDelegate {
        
        /// For more information take a look at `DelegateProxyType`.
        public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
            let switchButton: SwitchButton = castOrFatalError(object)
            switchButton.delegate = castOptionalOrFatalError(delegate)
        }
        
        /// For more information take a look at `DelegateProxyType`.
        public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
            let switchButton: SwitchButton = castOrFatalError(object)
            return switchButton.delegate
        }
    }
#endif

// MARK: Error binding policies

func bindingErrorToInterface(_ error: Swift.Error) {
    let error = "Binding error to UI: \(error)"
    #if DEBUG
        rxFatalError(error)
    #else
        print(error)
    #endif
}

// MARK: Abstract methods

func rxAbstractMethodWithMessage(_ message: String) -> Swift.Never  {
    rxFatalError(message)
}

func rxAbstractMethod() -> Swift.Never  {
    rxFatalError("Abstract method")
}

// MARK: casts or fatal error

// workaround for Swift compiler bug, cheers compiler team :)
func castOptionalOrFatalError<T>(_ value: Any?) -> T? {
    if value == nil {
        return nil
    }
    let v: T = castOrFatalError(value)
    return v
}

func castOptionalOrThrow<T>(_ resultType: T.Type, _ object: AnyObject) throws -> T? {
    if NSNull().isEqual(object) {
        return nil
    }
    
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    
    return returnValue
}

func castOrFatalError<T>(_ value: AnyObject!, message: String) -> T {
    let maybeResult: T? = value as? T
    guard let result = maybeResult else {
        rxFatalError(message)
    }
    
    return result
}

func castOrFatalError<T>(_ value: Any!) -> T {
    let maybeResult: T? = value as? T
    guard let result = maybeResult else {
        rxFatalError("Failure converting from \(value) to \(T.self)")
    }
    
    return result
}

// MARK: Error messages

let dataSourceNotSet = "DataSource not set"
let delegateNotSet = "Delegate not set"

// MARK: Shared with RxSwift

#if !RX_NO_MODULE
    
    func rxFatalError(_ lastMessage: String) -> Never  {
        // The temptation to comment this line is great, but please don't, it's for your own good. The choice is yours.
        fatalError(lastMessage)
    }
    
#endif
