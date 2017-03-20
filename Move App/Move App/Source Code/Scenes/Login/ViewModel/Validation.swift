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
    
    let minPhoneCount = 5
    let minPasswordCount = 8
    let maxPasswordCount = 16
    
    
    func validateNickName(_ name: String) ->ValidationResult {
        if name.characters.count == 0 {
            return .empty
        }
        
        return .ok(message: "Name available")
    }
    
    func validatePhone(_ phone: String) -> ValidationResult {
        let numberOfCharacters = phone.characters.count
        if phone.characters.count == 0 {
            return .empty
        }
        
        if numberOfCharacters < minPhoneCount {
            return .failed(message: "Phone must be at least \(minPhoneCount) characters")
        }
        
        return .ok(message: "Phone available")
    }

    
    func validateEmail(_ email: String) -> ValidationResult {
        if email.characters.count == 0 {
            return .empty
        }
        
        let prdEmail = NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z0-9_\\-\\.]{1,}@[a-zA-Z0-9_\\-]{1,}\\.[a-zA-Z0-9_\\-.]{1,}$")
        if !prdEmail.evaluate(with: email) {
            return .failed(message: "Not an email address")
        }
        
        return .ok(message: "Email available")
    }
    
    func validatePassword(_ password: String) -> ValidationResult {
        let numberOfCharacters = password.characters.count
        if numberOfCharacters == 0 {
            return .empty
        }
        
        if numberOfCharacters < minPasswordCount {
            return .failed(message: "Password must be at least \(minPasswordCount) characters")
        }
        
        let setString = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        for character in password.characters {
            if setString.characters.index(of: character) == nil {
                return .failed(message: "In passwords, space and Special symbols not allowed.")
            }
        }
        
        
        return .ok(message: "Password acceptable")
    }
    
    func validateRePassword(_ password: String, rePasswd: String) -> ValidationResult {
        if rePasswd.characters.count == 0{
            return .empty
        }
        
        if password != rePasswd {
            return .failed(message: "Twice input password not same")
        }
        
        let setString = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        for character in password.characters {
            if setString.characters.index(of: character) == nil {
                return .failed(message: "In passwords, space and Special symbols not allowed.")
            }
        }
        
        return .ok(message: "Password acceptable")
    }
}

