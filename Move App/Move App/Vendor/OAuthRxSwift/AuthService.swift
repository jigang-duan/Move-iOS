//
//  AuthService.swift
//  Move App
//
//  Created by jiang.duan on 2017/3/17.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import OAuthSwift
import RxSwift

class AuthService {
    
    static let shared = AuthService()
    
    // MARK: Twitter
    func twitter(consumerKey: String, consumerSecret: String, authorizeURLHandler: OAuthSwiftURLHandlerType) -> Observable<OAuthSwift.ObservableElement> {
        let oauthswift = OAuth1Swift(
            consumerKey:    consumerKey,
            consumerSecret: consumerSecret,
            requestTokenUrl: "https://api.twitter.com/oauth/request_token",
            authorizeUrl:    "https://api.twitter.com/oauth/authorize",
            accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
        )
        oauthswift.authorizeURLHandler = authorizeURLHandler
        return oauthswift.rx.authorize(with: URL(string: "http://oauthswift.herokuapp.com/callback/twitter")!)
    }
    
    // MAK : Facebook
    func facebook(consumerKey: String, consumerSecret: String, state: String, authorizeURLHandler: OAuthSwiftURLHandlerType) -> Observable<OAuthSwift.ObservableElement> {
        let oauthswift = OAuth2Swift(
            consumerKey:    consumerKey,
            consumerSecret: consumerSecret,
            authorizeUrl:   "https://www.facebook.com/dialog/oauth",
            accessTokenUrl: "https://graph.facebook.com/oauth/access_token",
            responseType:   "code"
        )
        
        oauthswift.authorizeURLHandler = authorizeURLHandler
        return oauthswift.rx.authorize(with: URL(string: "https://oauthswift.herokuapp.com/callback/facebook")!,
                                       scope: "public_profile",
                                       state: state)
        
    }
    
    // MAK : Google Drive
    func googleDrive(consumerKey: String, consumerSecret: String, state: String, authorizeURLHandler: OAuthSwiftURLHandlerType) -> Observable<OAuthSwift.ObservableElement> {
        let oauthswift = OAuth2Swift(
            consumerKey:    consumerKey,
            consumerSecret: consumerSecret,
            authorizeUrl:   "https://accounts.google.com/o/oauth2/auth",
            accessTokenUrl: "https://accounts.google.com/o/oauth2/token",
            responseType:   "code"
        )
        // For googgle the redirect_uri should match your this syntax: your.bundle.id:/oauth2Callback
        oauthswift.authorizeURLHandler = authorizeURLHandler
        return oauthswift.rx.authorize(with: URL(string: "https://oauthswift.herokuapp.com/callback/google")!,
                                       scope: "https://www.googleapis.com/auth/drive",
                                       state: state)
    }
    
}
