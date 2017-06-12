//
//  WorkerError.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/21.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum WorkerError: Swift.Error, Equatable {
    case emptyField(String)
    case expired(String)
    
    case webApi(id: Int, field: String?, msg: String?)
    
    case deviceNo
    
    case messageNotFound
    
    case LocationTimeout
}

func ==(lhs: WorkerError, rhs: WorkerError) -> Bool {
    
    switch (lhs, rhs) {
    case (.emptyField(let a), .emptyField(let b)) where a == b: return true
    case (.expired(let a), .expired(let b)) where a == b: return true
        
    case (.webApi(let a1, let a2, let a3), .webApi(let b1, let b2, let b3)) where ((a1 == b1) && (a2 == b2) && (a3 == b3)) : return true
    case (.deviceNo, .deviceNo): return true
        
    case (.messageNotFound, .messageNotFound): return true
    
    case (.LocationTimeout, .LocationTimeout): return true
    
    default: return false
    }
}

extension WorkerError {
    

    static func messageNotFoundError(form error: Swift.Error) -> WorkerError? {
        guard let
            error = error as? MoveApi.ApiError,
            error.id == 6 else {
            return nil
        }
        return WorkerError.messageNotFound
    }
    
    static func workerError (form error: Swift.Error) -> Swift.Error? {
        if let _error = error as? MoveApi.ApiError {
            return WorkerError.webApi(id: _error.id!, field: _error.field, msg: _error.msg)
        }
        if let _error = error as? WorkerError {
            return _error
        }
        return nil
    }
    
    static func errorTransform(from error: Swift.Error) -> String {
        guard let apiError = workerError(form: error) as? WorkerError else {
            return error.localizedDescription
        }
        
        if apiError == .LocationTimeout {
            return "Location Timeout"
        }
        
        return apiErrorTransform(from: apiError)
    }
    
    static func timeoutAndApiErrorTransform(from error: Swift.Error) -> String {
        guard let apiError = workerError(form: error) as? WorkerError else {
            return ""
        }
        
        if apiError == .LocationTimeout {
            return "Location Timeout"
        }
        
        return apiErrorTransform(from: apiError)
    }
    
    
    /**  ------error_id------
     0      Success: 成功，没有错误
     1      Unsupported: 不支持的功能
     2      Required: 参数缺失
     3      Type Error: 参数类型不匹配
     4      Parameter Error: 请求参数错误
     5      Invalid: 非法或已失效
     6      Not Found: 未找到
     7      Exist: 已存在
     8      Database Error: 数据库错误
     9      Internal Error: 服务器内部错误
     10     Unauthorized: 未授权操作
     11     Forbidden: 操作被禁止
     12     Locked: 被锁定
     ...    … 后续添加
    */
    static func apiErrorTransform(from error: WorkerError) -> String {
        var errorMessage = ""
        
        if case WorkerError.webApi(let id, let field, let msg) = error {
            
            switch id {
            case 0:
                break
            case 1:
                switch field ?? "" {
                default:
                    errorMessage = "\(field ?? "") \(msg ?? "")"
                }
            case 2:
                switch field ?? "" {
                default:
                    errorMessage = "\(field ?? "") \(msg ?? "")"
                }
            case 3:
                switch field ?? "" {
                default:
                    errorMessage = "\(field ?? "") \(msg ?? "")"
                }
            case 4:
                switch field ?? "" {
                default:
                    errorMessage = "\(field ?? "") \(msg ?? "")"
                }
            case 5:
                switch field ?? "" {
                case "password":
                    errorMessage = R.string.localizable.id_password_not_same()
                case "vcode":
                    errorMessage = "This code has expired"
                default:
                    errorMessage = "\(field ?? "") \(msg ?? "")"
                }
            case 6:
                switch field ?? "" {
                case "account":
                    errorMessage = "Account doesn’t exist."
                default:
                    errorMessage = "\(field ?? "") \(msg ?? "")"
                }
            case 7:
                switch field ?? "" {
                case "identity":
                    errorMessage = "Identity existed"
                case "username":
                    errorMessage = "Account already exists"
                default:
                    errorMessage = "\(field ?? "") \(msg ?? "")"
                }
            case 8:
                switch field ?? "" {
                default:
                    errorMessage = "\(field ?? "") \(msg ?? "")"
                }
            case 9:
                switch field ?? "" {
                default:
                    errorMessage = "\(field ?? "") \(msg ?? "")"
                }
            case 10:
                switch field ?? "" {
                default:
                    errorMessage = "\(field ?? "") \(msg ?? "")"
                }
            case 11:
                switch field ?? "" {
                default:
                    errorMessage = ""
                }
            case 12:
                switch field ?? "" {
                default:
                    errorMessage = "\(field ?? "") \(msg ?? "")"
                }
            case 14:
                switch msg ?? "" {
                case "Excess error":
                    errorMessage = "Watch can add most 10 members"
                default:
                    errorMessage = "\(field ?? "") \(msg ?? "")"
                }
            default:
                break
            }
            
        }
        
        return errorMessage
    }
    
    
}


func errorTransform(error: MoveApi.ApiError) throws -> Bool {
    if error.msg == "ok", error.id == 0 {
        return true
    }
    throw WorkerError.webApi(id: error.id!, field: error.field, msg: error.msg)
}


func errorHandle(error: Error) throws -> Observable<Bool> {
    if let _error = WorkerError.workerError(form: error) {
        throw _error
    }
    throw error
}




func commonErrorRecover(_ error: Error) -> Driver<ValidationResult> {
    guard let _error = error as?  WorkerError else {
        return Driver.just(ValidationResult.empty)
    }
    
    let msg = WorkerError.apiErrorTransform(from: _error)
    return Driver.just(ValidationResult.failed(message: msg))
}









