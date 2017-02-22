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
    
    let minEmailCount = 5
    let minPasswordCount = 5
    
    func validateAccount(_ account: String) -> ValidationResult {
        let numberOfCharacters = account.characters.count
        if account.characters.count == 0 {
            return .empty
        }
        
        if numberOfCharacters < minEmailCount {
            return .failed(message: "Account must be at least \(minEmailCount) characters")
        }
        
        return .ok(message: "Account available")
    }
    
    func validateEmail(_ email: String) -> ValidationResult {
        let numberOfCharacters = email.characters.count
        if email.characters.count == 0 {
            return .empty
        }
        
        if numberOfCharacters < minEmailCount {
            return .failed(message: "Email must be at least \(minEmailCount) characters")
        }
        
        if !email.contains("@"){
            return .failed(message: "Email address not correct")
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
        
        return .ok(message: "Password acceptable")
    }
    
    func validateRePassword(_ password: String, rePasswd: String) -> ValidationResult {
        if password != rePasswd {
            return .failed(message: "Twice input password not same")
        }
        
        return .ok(message: "Password acceptable")
    }
}

