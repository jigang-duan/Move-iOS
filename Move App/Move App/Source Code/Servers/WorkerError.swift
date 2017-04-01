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
}

func ==(lhs: WorkerError, rhs: WorkerError) -> Bool {
    
    switch (lhs, rhs) {
    case (.emptyField(let a), .emptyField(let b)) where a == b: return true
    case (.expired(let a), .expired(let b)) where a == b: return true
        
    case (.webApi(let a1, let a2, let a3), .webApi(let b1, let b2, let b3)) where ((a1 == b1) && (a2 == b2) && (a3 == b3)) : return true
    case (.deviceNo, .deviceNo): return true
        
    case (.messageNotFound, .messageNotFound): return true
        
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
    
    static func accountNotFoundError (form error: Swift.Error) -> Swift.Error? {
        if let _error = error as? MoveApi.ApiError {
            if _error.id == 6 && _error.field == "account" {
                return WorkerError.accountNotFound
            }
        }
        return nil
    }
    
    static func workerError (form error: Swift.Error) -> Swift.Error? {
        if let _error = error as? MoveApi.ApiError {
            return WorkerError.webApi(id: _error.id!, field: _error.field, msg: _error.msg)
        }
        return nil
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
                    errorMessage = "\(msg) Unsupported"
                }
            case 2:
                switch field ?? "" {
                default:
                    errorMessage = "\(msg) Required"
                }
            case 3:
                switch field ?? "" {
                default:
                    errorMessage = "\(msg) Type Error"
                }
            case 4:
                switch field ?? "" {
                default:
                    errorMessage = "\(msg) Parameter Error"
                }
            case 5:
                switch field ?? "" {
                case "password":
                    errorMessage = "password Invalid"
                case "vcode":
                    errorMessage = "vcode Invalid"
                default:
                    errorMessage = "\(msg) Invalid"
                }
            case 6:
                switch field ?? "" {
                case "account":
                    errorMessage = "account Not Found"
                default:
                    errorMessage = "\(msg) Not Found"
                }
            case 7:
                switch field ?? "" {
                case "identity":
                    errorMessage = "identity Exist"
                case "username":
                    errorMessage = "username Exist"
                default:
                    errorMessage = "\(msg) Exist"
                }
            case 8:
                switch field ?? "" {
                default:
                    errorMessage = "\(msg) Database Error"
                }
            case 9:
                switch field ?? "" {
                default:
                    errorMessage = "\(msg) Internal Error"
                }
            case 10:
                switch field ?? "" {
                default:
                    errorMessage = "\(msg) Unauthorized"
                }
            case 11:
                switch field ?? "" {
                default:
                    errorMessage = "\(msg) Forbidden"
                }
            case 12:
                switch field ?? "" {
                default:
                    errorMessage = "\(msg) Locked"
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









