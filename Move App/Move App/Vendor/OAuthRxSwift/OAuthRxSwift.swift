//
//  OAuthRxSwift.swift
//  Move App
//
//  Created by jiang.duan on 2017/3/17.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import OAuthSwift
import RxSwift

extension OAuthSwift {
    public typealias ObservableElement = (credential: OAuthSwiftCredential, response: OAuthSwiftResponse?, parameters: Parameters) // see OAuthSwift.TokenSuccessHandler TODO replace with OAuthSwift.TokenSuccess
}

extension Reactive where Base: OAuth1Swift {

    func authorize(with callbackURL: URL) -> Observable<OAuthSwift.ObservableElement> {
        return Observable<OAuthSwift.ObservableElement>.create{ (observer: AnyObserver<OAuthSwift.ObservableElement>) -> Disposable in
            let handle = self.base.authorize(withCallbackURL: callbackURL,
                                             success: { (credential: OAuthSwiftCredential, response: OAuthSwiftResponse?, parameters: OAuthSwift.Parameters) in
                                                observer.onNext((credential, response, parameters))
                                                observer.onCompleted()
            }, failure: { (error: OAuthSwiftError) in
                observer.onError(error)
            })
            
            return Disposables.create {
                handle?.cancel()
            }
        }
            .share()
    }
    
    func authorize(with callbackURL: String) -> Observable<OAuthSwift.ObservableElement> {
        return Observable<OAuthSwift.ObservableElement>.create({ (observer: AnyObserver<OAuthSwift.ObservableElement>) -> Disposable in
            let handle = self.base.authorize(withCallbackURL: callbackURL,
                                             success: { (credential: OAuthSwiftCredential, response: OAuthSwiftResponse?, parameters: OAuthSwift.Parameters) in
                                                observer.onNext((credential, response, parameters))
                                                observer.onCompleted()
            },
                                             failure: { (error: OAuthSwiftError) in
                                                observer.onError(error)
            })
            
            return Disposables.create {
                handle?.cancel()
            }
        })
            .share()
    }

}

extension Reactive where Base: OAuth2Swift {
    
    func authorize(with callbackURL: URL, scope: String, state: String) -> Observable<OAuthSwift.ObservableElement> {
        return Observable<OAuthSwift.ObservableElement>.create({ (observer: AnyObserver<OAuthSwift.ObservableElement>) -> Disposable in
            let handle = self.base.authorize(withCallbackURL: callbackURL,
                                             scope: scope,
                                             state: state,
                                             success: { (credential: OAuthSwiftCredential, response: OAuthSwiftResponse?, parameters: OAuthSwift.Parameters) in
                                                observer.onNext((credential, response, parameters))
                                                observer.onCompleted()
            },
                                             failure: { (error: OAuthSwiftError) in
                                                observer.onError(error)
            })
            
            return Disposables.create {
                handle?.cancel()
            }
        })
            .share()
    }
    
    
    func authorize(with callbackURL: String, scope: String, state: String) -> Observable<OAuthSwift.ObservableElement> {
        return Observable<OAuthSwift.ObservableElement>.create({ (observer: AnyObserver<OAuthSwift.ObservableElement>) -> Disposable in
            let handle = self.base.authorize(withCallbackURL: callbackURL,
                                             scope: scope,
                                             state: state,
                                             success: { (credential: OAuthSwiftCredential, response: OAuthSwiftResponse?, parameters: OAuthSwift.Parameters) in
                                                observer.onNext((credential, response, parameters))
                                                observer.onCompleted()
            },
                                             failure: { (error: OAuthSwiftError) in
                                                observer.onError(error)
            })
            
            return Disposables.create {
                handle?.cancel()
            }
        })
            .share()
    
    }
    
}


