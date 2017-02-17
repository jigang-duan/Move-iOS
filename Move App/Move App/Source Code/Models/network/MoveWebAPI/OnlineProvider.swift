//
//  OnlineProvider.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/16.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import Moya
import RxSwift


class OnlineProvider<Target>: RxMoyaProvider<Target> where Target: TargetType {
    
    // First of all, we need to override designated initializer
    override init(endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure = MoyaProvider.defaultEndpointMapping,
         requestClosure: @escaping MoyaProvider<Target>.RequestClosure = MoyaProvider.defaultRequestMapping,
         stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider.neverStub,
         manager: Manager = RxMoyaProvider<Target>.defaultAlamofireManager(),
         plugins: [PluginType] = [],
         trackInflights: Bool = false) {
        
        super.init(endpointClosure: endpointClosure,
                   requestClosure: requestClosure,
                   stubClosure: stubClosure,
                   manager: manager,
                   plugins: plugins,
                   trackInflights: trackInflights)
    }
    
    // Request to fetch and store new XApp token if the current token is missing or expired.
    func XAppTokenRequest() -> Observable<String?> {
        
        let appToken = UserInfo.shared.accessToken
        
        // If we have a valid token, just return it
        if appToken.isValidAndNotExpired {
            return Observable.just(appToken.token)
        }
        
        // Do not attempt to refresh a session if we don't have valid credentials
        guard let _ = UserInfo.shared.id,
            let _ = UserInfo.shared.accessToken.refreshToken else {
            UserInfo.shared.invalidate()
            if MoveApi.canPopToLoginScreen {
                Distribution.shared.popToLoginScreen()
            }
            return Observable.error(NSError.userAuthorizationError())
        }
        
        return MoveApi.Account.refreshToken()
            .map { $0.accessToken.token }
            .catchError { e -> Observable<String?> in
                guard let error = e as? MoveApi.ApiError else { throw e }
                guard let errorId = error.id else { throw e }
            
                if errorId == 10 {
                    UserInfo.shared.invalidate()
                    if MoveApi.canPopToLoginScreen {
                        Distribution.shared.popToLoginScreen()
                    }
                }
                throw error
        }
    }
    
    override func request(_ token: Target) -> Observable<Response> {
        let actualRequest = super.request(token)
        
        return self.XAppTokenRequest().flatMap { _ in
            actualRequest
        }
    }
}
