//
//  LoginViewModel.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/20.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class LoginViewModel {
    // outputs {
    
    //
    let validatedEmail: Driver<ValidationResult>
    let validatedPassword: Driver<ValidationResult>
    
    // Is login button enabled
    let loginEnabled: Driver<Bool>
    
    // Has user signed in
    let logedIn: Driver<ValidationResult>
    
    // Is signing process in progress
    let loggingIn: Driver<Bool>
    
    let thirdLoginResult: Driver<ValidationResult>
    
    init(
        input: (
        email: Driver<String>,
        passwd: Driver<String>,
        loginTaps: Driver<Void>,
        thirdLogin: Driver<MoveApiUserWorker.LoginType>
        ),
        dependency: (
        userManager: UserManager,
        validation: DefaultValidation,
        wireframe: Wireframe
        )
    ) {
        
        let userManager = dependency.userManager
        let validation = dependency.validation
        let _ = dependency.wireframe
        
        validatedEmail = input.email
            .map { validation.validateEmail($0) }
        
        validatedPassword = input.passwd
            .map { validation.validatePassword($0) }
        
        let signingIn = ActivityIndicator()
        self.loggingIn = signingIn.asDriver()
        
        let emailAndPassword = Driver.combineLatest(input.email, input.passwd) { ($0, $1) }
        
        self.logedIn = input.loginTaps.withLatestFrom(emailAndPassword)
            .flatMapLatest({ (email, password) in
                return userManager.login(email: email, password: password)
                    .trackActivity(signingIn)
                    .map { _ in
                        ValidationResult.ok(message: "Login Success.")
                    }
                    .asDriver(onErrorRecover: commonErrorRecover)
            })
        
        self.loginEnabled = Driver.combineLatest(
            validatedEmail,
            validatedPassword,
            loggingIn) { email, password, loggingIn in
                email.isValid &&
                password.isValid &&
                !loggingIn
            }
            .distinctUntilChanged()
        
        
        let third = input.thirdLogin.filter({ $0 != MoveApiUserWorker.LoginType.none })
        
        self.thirdLoginResult = third.flatMapLatest({ type in
            var platformType: SSDKPlatformType?
            switch type {
            case .facebook:
                platformType = .typeFacebook
            case .twitter:
                platformType = .typeTwitter
            case .google:
                platformType = .typeGooglePlus
            default:
                platformType = .typeUnknown
            }
            
            let auth = ShareSDK.authorize(SSDKPlatformType: platformType!).flatMap({user -> Observable<ValidationResult> in
                var openid = ""
                var secret = ""
                switch type {
                case .facebook:
                    openid = "344365305959182"//facebook ID
                    secret = user.credential.token
                case .twitter:
                    openid = user.credential.token
                    secret = user.credential.secret
                case .google:
                    openid = user.credential.token
                    secret = user.credential.rawData["id_token"] as? String ?? ""
                default:
                    break
                }
                
                let loginRes = userManager.tplogin(platform: type, openld: openid, secret: secret)
                    .trackActivity(signingIn)
                    .map { _ in
                        ValidationResult.ok(message: "Login Success.")
                }
                
                return loginRes
            })
            
            return auth.asDriver(onErrorRecover: commonErrorRecover)
        })
        
        
        
    }
    
}


extension ShareSDK {
    
    class func authorize(SSDKPlatformType: SSDKPlatformType, settings: [AnyHashable: Any] = [:]) -> Observable<SSDKUser> {
        
        return Observable<SSDKUser>.create{ (observer: AnyObserver<SSDKUser>) -> Disposable in
            
            ShareSDK.authorize(SSDKPlatformType, settings: settings, onStateChanged: { (state, user, error) in
                switch state{
                case .success:
                    observer.onNext(user!)
                    observer.onCompleted()
                    print("授权成功,用户信息为\(user)\n ----- 授权凭证为\(user?.credential)")
                case .fail:
                    observer.onError(error!)
                    print("授权失败,错误描述:\(error)")
                default:
                    observer.onCompleted()
                }
            })
            
            return Disposables.create()
            }
            .share()
    }
}




