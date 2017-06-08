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
//        _plugins.append(MoveApiAccountTokenPlugin())
        
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
            .tokenError()
            .catchError(catchTokenError)
            .debug()
    }
}

func catchTokenError(_ error: Swift.Error) throws -> Observable<Response> {
    guard let apiError = error as? MoveApi.ApiError else { throw error }
    guard apiError.id != nil else { throw error }
    
    guard
        let _ = UserInfo.shared.id,
        let _ = UserInfo.shared.accessToken.refreshToken else {
            return Observable.error(NSError.userAuthorizationError())
    }
    
    if apiError.isTokenExpired {
        UserInfo.shared.invalidate()
        UserInfo.shared.clean()
        if MoveApi.canPopToLoginScreen {
            Distribution.shared.popToLoginScreen(true)
        }
        throw error
    }
    
    if apiError.isTokenForbidden {
        if let username = apiError.msg {
            return MoveApi.Account.loginLofo(username: username)
                .map { (deviceName: $0.deviceName, loginDate: $0.date) }
                .do(onNext: { (deviceName: String?, loginDate: Date?) in
                    UserInfo.shared.invalidate()
                    UserInfo.shared.clean()
                    if MoveApi.canPopToLoginScreen {
                        Distribution.shared.popToLoginScreen(true, name: deviceName, date: loginDate)
                    }
                })
                .flatMapLatest({ (_) -> Observable<Response> in
                    Observable.error(NSError.tokenForbiddenError())
                })
        }
        UserInfo.shared.invalidate()
        UserInfo.shared.clean()
        if MoveApi.canPopToLoginScreen {
            Distribution.shared.popToLoginScreen(true)
        }
        throw error
    }
    
    throw error
}

fileprivate extension ObservableType where E == Response {
    
    func tokenError() -> Observable<Response> {
        return self.flatMapLatest { (response) -> Observable<Response> in
            guard response.statusCode == 403 else {
                return Observable.just(response)
            }
            
            do {
                _ = try response.mapMoveObject(MoveApi.ApiError.self)
            } catch {
                if let err = error as? MoveApi.ApiError, err.isTokenForbidden {
                    return Observable.error(err.tokenForbiddenError(username: UserInfo.shared.profile?.username))
                }
                if let err = error as? MoveApi.ApiError, err.isTokenExpired {
                    return Observable.error(err)
                }
            }
            
            return Observable.just(response)
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
                    UserInfo.shared.invalidate()
                    UserInfo.shared.clean()
                    if MoveApi.canPopToLoginScreen {
                        Distribution.shared.popToLoginScreen(true)
                    }
                }
        }
        
    }
}
