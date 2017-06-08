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
import Result


class OnlineProvider<Target>: RxMoyaProvider<Target> where Target: TargetType {
    
    // First of all, we need to override designated initializer
    override init(endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure = MoyaProvider.defaultEndpointMapping,
         requestClosure: @escaping MoyaProvider<Target>.RequestClosure = MoyaProvider.defaultRequestMapping,
         stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider.neverStub,
         manager: Manager = RxMoyaProvider<Target>.defaultAlamofireManager(),
         plugins: [PluginType] = [],
         trackInflights: Bool = false) {
        
        var _plugins = plugins
        _plugins.append(MoveApiAccountTokenPlugin())
        
        super.init(endpointClosure: endpointClosure,
                   requestClosure: requestClosure,
                   stubClosure: stubClosure,
                   manager: manager,
                   plugins: _plugins,
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
            UserInfo.shared.clean()
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
            
                if errorId == 11 {
                    UserInfo.shared.invalidate()
                    UserInfo.shared.clean()
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


final class MoveApiAccountTokenPlugin: PluginType {
    // MARK: Plugin
    
    /// Called by the provider as soon as a response arrives, even if the request is cancelled.
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        guard
            let response = result.value,
            response.statusCode == 403 else {
                return
        }
            
        do {
            _ = try response.mapMoveObject(MoveApi.ApiError.self)
        } catch {
            if
                let err = error as? MoveApi.ApiError,
                let errorId = err.id, errorId == 11,
                let error_field = err.field, error_field == "access_token" {
                    let userName = UserInfo.shared.profile?.username
                    UserInfo.shared.invalidate()
                    UserInfo.shared.clean()
                    if MoveApi.canPopToLoginScreen {
                        Distribution.shared.popToLoginScreen(true)
                    }
                }
        }
        
    }
}
