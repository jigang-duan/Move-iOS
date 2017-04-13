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
    
    let minPhoneCount = 3
    let minPasswordCount = 8
    let maxPasswordCount = 16
    
    
    func validateNickName(_ name: String) ->ValidationResult {
        if name.characters.count == 0 {
            return .empty
        }
        
        if name.hasPrefix(" ") || name.hasSuffix(" ") {
            return .failed(message: "Name invalid")
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
        
        let setString = "0123456789*#"
        for character in phone.characters {
            if setString.characters.index(of: character) == nil {
                return .failed(message: "Phone input incorrect")
            }
        }
        
        return .ok(message: "Phone available")
    }

    
    func validateMultiPhones(_ phoneStr: String) -> ValidationResult {
        let numberOfCharacters = phoneStr.characters.count
        if phoneStr.characters.count == 0 {
            return .empty
        }
        
        if numberOfCharacters < minPhoneCount {
            return .failed(message: "Phone must be at least \(minPhoneCount) characters")
        }
        
        let setString = "0123456789,*#"
        for character in phoneStr.characters {
            if setString.characters.index(of: character) == nil {
                return .failed(message: "Phones input incorrect")
            }
        }
        
        return .ok(message: "Phones available")
    }
    
    func validateEmail(_ email: String) -> ValidationResult {
        if email.characters.count == 0 {
            return .empty
        }
        
        let prdEmail = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}")
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
        
        if numberOfCharacters < minPasswordCount || numberOfCharacters > maxPasswordCount {
            return .failed(message: "Password must be \(minPasswordCount)-\(maxPasswordCount) letters and numbers")
        }
        
        let setRegex = NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z0-9]+$")
        if !setRegex.evaluate(with: password) {
            return .failed(message: "In passwords, space and Special symbols not allowed.")
        }
        
        let letterRegex = NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z]+$")
        if letterRegex.evaluate(with: password) {
            return .failed(message: "Password must be \(minPasswordCount)-\(maxPasswordCount) letters and numbers")
        }
        
        let lnumberRegex = NSPredicate(format: "SELF MATCHES %@", "^[0-9]+$")
        if lnumberRegex.evaluate(with: password) {
            return .failed(message: "Password must be \(minPasswordCount)-\(maxPasswordCount) letters and numbers")
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
        
        let setRegex = NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z0-9]+$")
        if !setRegex.evaluate(with: password) {
            return .failed(message: "In passwords, space and Special symbols not allowed.")
        }
        
        let letterRegex = NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z]+$")
        if letterRegex.evaluate(with: password) {
            return .failed(message: "Password must be \(minPasswordCount)-\(maxPasswordCount) letters and numbers")
        }
        
        let lnumberRegex = NSPredicate(format: "SELF MATCHES %@", "^[0-9]+$")
        if lnumberRegex.evaluate(with: password) {
            return .failed(message: "Password must be \(minPasswordCount)-\(maxPasswordCount) letters and numbers")
        }
        
        
        return .ok(message: "Password acceptable")
    }
}

