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
import Moya


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
            .map { pswd in
                if pswd.characters.count > 0 {
                    return ValidationResult.ok(message: "")
                }else{
                    return ValidationResult.empty
                }
            }
        
        let signingIn = ActivityIndicator()
        self.loggingIn = signingIn.asDriver()
        
        let emailAndPassword = Driver.combineLatest(input.email, input.passwd) { ($0, $1) }
        
        self.logedIn = input.loginTaps.withLatestFrom(emailAndPassword)
            .flatMapLatest{ (email, password) in
                userManager.login(email: email, password: password)
                    .trackActivity(signingIn)
                    .do(onNext: { _ in
                        UserDefaults.standard.setValue(email, forKey: lastLoginAccount)
                        UserDefaults.standard.setValue(password, forKey: lastLoginPassword)
                    })
                    .map { _ in .ok(message: "Login Success.") }
                    .asDriver(onErrorRecover: errorRecover)
            }
            .flatMapLatest(selector)
        
        self.loginEnabled = Driver.combineLatest(
            validatedEmail,
            validatedPassword,
            loggingIn) { email, password, loggingIn in
                email.isValid &&
                password.isValid &&
                !loggingIn
            }
            .distinctUntilChanged()
        
        
        let third = input.thirdLogin.filter { $0 != MoveApiUserWorker.LoginType.none }
        
        self.thirdLoginResult = third.flatMapLatest { type in
                ShareSDK.rx.authorize(SSDKPlatformType: type.ssdkPlatformType)
                    .flatMap { user -> Observable<ValidationResult> in
                        userManager.tplogin(platform: type, openld: type.openid(user: user) , secret: type.secret(user: user))
                            .trackActivity(signingIn)
                            .map { _ in ValidationResult.ok(message: "Login Success.") }
                    }
                    .asDriver(onErrorRecover: commonErrorRecover)
            }
            .flatMapLatest(selector)
        
    }
    
}

//MARK: ShareSDK type extensions

extension MoveApiUserWorker.LoginType {
    
    func secret(user: SSDKUser) -> String {
        switch self {
        case .facebook:
            return user.credential.token
        case .twitter:
            return user.credential.secret
        case .google:
            return user.credential.rawData["id_token"] as? String ?? ""
        default:
            return ""
        }
    }
    
    func openid(user: SSDKUser) -> String {
        switch self {
        case .facebook:
            return "344365305959182"    //facebook ID
        case .twitter:
            return user.credential.token
        case .google:
            return user.credential.token
        default:
            return ""
        }
    }
    
    var ssdkPlatformType: SSDKPlatformType {
        switch self {
        case .facebook:
            return .typeFacebook
        case .twitter:
            return .typeTwitter
        case .google:
            return .typeGooglePlus
        default:
            return .typeUnknown
        }
    }
}

extension Reactive where Base: ShareSDK {
    
    static func authorize(SSDKPlatformType: SSDKPlatformType, settings: [AnyHashable: Any] = [:]) -> Observable<SSDKUser> {
        return Observable<SSDKUser>.create{ (observer: AnyObserver<SSDKUser>) -> Disposable in
            
            ShareSDK.authorize(SSDKPlatformType, settings: settings, onStateChanged: { (state, user, error) in
                switch state {
                case .success:
                    observer.onNext(user!)
                    observer.onCompleted()
                case .fail:
                    observer.onError(error!)
                default:
                    observer.onCompleted()
                }
            })
            
            return Disposables.create()
            }
            .share()
    }
}


fileprivate func errorRecover(_ error: Swift.Error) -> Driver<ValidationResult> {
    if let merror = error as?  MoyaError {
        if case MoyaError.underlying(_) = merror {
            ProgressHUD.show(status: R.string.localizable.id_network_unavailable())
        }
    }
    
    guard let _error = error as?  WorkerError else {
        return Driver.just(ValidationResult.failed(message: "network failed."))
    }
    
    let msg = WorkerError.verifyErrorTransform(from: _error)
    return Driver.just(ValidationResult.failed(message: msg))
}

func selector(result: ValidationResult) -> Driver<ValidationResult> {
    switch result {
    case .ok:
        return DeviceManager.shared.fetchDevices()
            .takeLast(1)
            .map { $0.count > 0 ? .ok(message: "Login Success.") : .empty }
            .asDriver(onErrorRecover: commonErrorRecover)
    default:
        return Driver.just(result)
    }
}
