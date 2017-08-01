//
//  Validation.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/20.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum ValidationResult {
    case ok(message: String)
    case empty
    case validating
    case failed(message: String)
}

extension ValidationResult {
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}

extension ValidationResult {
    var isEmpty: Bool {
        switch self {
        case .empty:
            return true
        default:
            return false
        }
    }
}

extension ValidationResult: CustomStringConvertible {
    var description: String {
        switch self {
        case let .ok(message):
            return message
        case .empty:
            return ""
        case .validating:
            return "validating ..."
        case let .failed(message):
            return message
        }
    }
}

struct ValidationColors {
    static let okColor = R.color.appColor.divider()
    static let errorColor = R.color.appColor.wrong()
}

extension ValidationResult {
    var textColor: UIColor {
        switch self {
        case .ok:
            return ValidationColors.okColor
        case .empty:
            return UIColor.black
        case .validating:
            return UIColor.black
        case .failed:
            return ValidationColors.errorColor
        }
    }
}

extension Reactive where Base: UILabel {
    var validationResult: UIBindingObserver<Base, ValidationResult> {
        return UIBindingObserver(UIElement: base) { label, result in
            label.textColor = result.textColor
            label.text = result.description
        }
    }
}


class DefaultValidation {
    
    static let shared = DefaultValidation()
    // validation
    
    let minPasswordCount = 8
    let maxPasswordCount = 16
    
    //昵称
    func validateNickName(_ name: String) ->ValidationResult {
        if name.characters.count == 0 {
            return .empty
        }
        
        if name.hasPrefix(" ") || name.hasSuffix(" ") {
            return .failed(message: "Name invalid")
        }
        
        return .ok(message: "Name available")
    }
    //电话号码
    func validatePhone(_ phone: String) -> ValidationResult {
        let numberOfCharacters = phone.characters.count
        if numberOfCharacters == 0 {
            return .empty
        }
        
        if numberOfCharacters < 3 {
            return .failed(message: R.string.localizable.id_phone_number_less_three())
        }
        
        let setString = "0123456789"
        for character in phone.characters {
            if setString.characters.index(of: character) == nil {
                return .failed(message: R.string.localizable.id_phone_error())
            }
        }
        
        return .ok(message: "Phone available")
    }

    //多个电话号码
    func validateMultiPhones(_ phoneStr: String) -> ValidationResult {
        let numberOfCharacters = phoneStr.characters.count
        if phoneStr.characters.count == 0 {
            return .empty
        }
        
        if numberOfCharacters < 3 {
            return .failed(message: R.string.localizable.id_phone_number_less_three())
        }
        
        let setString = "0123456789,"
        for character in phoneStr.characters {
            if setString.characters.index(of: character) == nil {
                return .failed(message: R.string.localizable.id_phone_error())
            }
        }
        
        return .ok(message: "Phones available")
    }
    //邮箱
    func validateEmail(_ email: String) -> ValidationResult {
        if email.characters.count == 0 {
            return .empty
        }
        
        let prdEmail = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}")
        if !prdEmail.evaluate(with: email) {
            return .failed(message: R.string.localizable.id_email_invalid())
        }
        
        return .ok(message: "Email available")
    }
    //IMEI号
    func validateIMEI(_ imei: String) -> ValidationResult {
        if imei.characters.count == 0 {
            return .empty
        }
        
        if imei.characters.count != 15 {
            return .failed(message: "15 numbers only")
        }
        
        let prdImei = NSPredicate(format: "SELF MATCHES %@", "^[0-9]+$")
        if !prdImei.evaluate(with: imei) {
            return .failed(message: "15 numbers only")
        }
        
        return .ok(message: "IMEI available")
    }
    //验证码
    func validateVCode(_ vcode: String) -> ValidationResult {
        if vcode.characters.count == 0 {
            return .empty
        }
        
        if vcode.characters.count != 6 {
            return .failed(message: "6 numbers only")
        }
        
        let prdCode = NSPredicate(format: "SELF MATCHES %@", "^[0-9]+$")
        if !prdCode.evaluate(with: vcode) {
            return .failed(message: "6 numbers only")
        }
        
        return .ok(message: "Vcode available")
    }
    //密码
    func validatePassword(_ password: String) -> ValidationResult {
        let numberOfCharacters = password.characters.count
        if numberOfCharacters == 0 {
            return .empty
        }
        
        if numberOfCharacters < minPasswordCount || numberOfCharacters > maxPasswordCount {
            return .failed(message: R.string.localizable.id_password_8_16_letters_or_numbers())
        }
        
        let setRegex = NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z0-9]+$")
        if !setRegex.evaluate(with: password) {
            return .failed(message: R.string.localizable.id_register_password_hint())
        }
        
//        let letterRegex = NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z]+$")
//        if letterRegex.evaluate(with: password) {
//            return .failed(message: R.string.localizable.id_password_8_16_letters_or_numbers())
//        }
//        
//        let lnumberRegex = NSPredicate(format: "SELF MATCHES %@", "^[0-9]+$")
//        if lnumberRegex.evaluate(with: password) {
//            return .failed(message: R.string.localizable.id_password_8_16_letters_or_numbers())
//        }
        
        
        return .ok(message: "Password acceptable")
    }
    //确认密码
    func validateRePassword(_ password: String, rePasswd: String) -> ValidationResult {
        if rePasswd.characters.count == 0{
            return .empty
        }
        
        if password != rePasswd {
            return .failed(message: "Two passwords are inconsistent")
        }
        
        let setRegex = NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z0-9]+$")
        if !setRegex.evaluate(with: password) {
            return .failed(message: R.string.localizable.id_register_password_hint())
        }
        
//        let letterRegex = NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z]+$")
//        if letterRegex.evaluate(with: password) {
//            return .failed(message: R.string.localizable.id_password_8_16_letters_or_numbers())
//        }
//        
//        let lnumberRegex = NSPredicate(format: "SELF MATCHES %@", "^[0-9]+$")
//        if lnumberRegex.evaluate(with: password) {
//            return .failed(message: R.string.localizable.id_password_8_16_letters_or_numbers())
//        }
        
        
        return .ok(message: "Password acceptable")
    }
}

