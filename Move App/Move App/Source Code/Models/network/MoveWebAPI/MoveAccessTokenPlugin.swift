//
//  MoveAccessTokenPlugin.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/7.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import Moya

struct MoveAccessTokenPlugin: PluginType {
    
    /// The access token to be applied in the header.
    public var token: String {
        get {
            return UserInfo.shared.accessToken.token ?? ""
        }
    }
    
    private var authenCryptorToken: String {
        let uidData = UserInfo.shared.id?.data(using: String.Encoding.utf8)
        return AuthenCryptor.token(withUid: uidData) ?? ""
    }
    
    private var authVal: String {
        return "\(MoveApi.apiKey);token=\(token);\(authenCryptorToken)"
    }
    
    /**
     Prepare a request by adding an authorization header if necessary.
     
     - parameters:
     - request: The request to modify.
     - target: The target of the request.
     - returns: The modified `URLRequest`.
     */
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        if let authorizable = target as? AccessTokenAuthorizable, authorizable.shouldAuthorize == false {
            return request
        }
        
        var request = request
        if let strAuth = request.allHTTPHeaderFields?["Authorization"] {
            request.setValue("\(strAuth);token=\(token);\(authenCryptorToken)", forHTTPHeaderField: "Authorization")
            
        } else {
            request.setValue(authVal, forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
}
