//
//  WorkerError.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/21.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation

enum WorkerError: Swift.Error, Equatable {
    case emptyField(String)
    case expired(String)
    
    case webApi(id: Int, field: String?, msg: String?)
    case accountNotFound
    case accountIsExist
    case password
    case identityIsExist
    
    case vcodeIsIncorrect
    
    case deviceNo
}

func ==(lhs: WorkerError, rhs: WorkerError) -> Bool {
    
    switch (lhs, rhs) {
    case (.emptyField(let a), .emptyField(let b)) where a == b: return true
    case (.expired(let a), .expired(let b)) where a == b: return true
        
    case (.webApi(let a1, let a2, let a3), .webApi(let b1, let b2, let b3)) where ((a1 == b1) && (a2 == b2) && (a3 == b3)) : return true
    case (.accountNotFound, .accountNotFound): return true
    case (.accountIsExist, .accountIsExist): return true
    case (.password, .password): return true
    case (.identityIsExist, .identityIsExist): return true
       
    case (.vcodeIsIncorrect, .vcodeIsIncorrect): return true
    case (.deviceNo, .deviceNo): return true
        
    default: return false
    }
}

extension WorkerError {
    
    static func accountNotFoundError (form error: Swift.Error) -> Swift.Error? {
        if let _error = error as? MoveApi.ApiError {
            if _error.id == 6 && _error.field == "account" {
                return WorkerError.accountNotFound
            }
        }
        return nil
    }
    
    static func accountIsExistError (form error: Swift.Error) -> Swift.Error? {
        if let _error = error as? MoveApi.ApiError {
            if _error.id == 7 && _error.field == "username" {
                return WorkerError.accountIsExist
            }
        }
        return nil
    }
    
    static func passwordError (form error: Swift.Error) -> Swift.Error? {
        if let _error = error as? MoveApi.ApiError {
            if _error.id == 5 && _error.field == "password" {
                return WorkerError.password
            }
        }
        return nil
    }
    
    static func vcodeIsIncorrectError (form error: Swift.Error) -> Swift.Error? {
        if let _error = error as? MoveApi.ApiError {
            if _error.id == 5 && _error.field == "vcode" {
                return WorkerError.vcodeIsIncorrect
            }
        }
        return nil
    }
    
    static func identityIsExistError (form error: Swift.Error) -> Swift.Error? {
        if let _error = error as? MoveApi.ApiError {
            if _error.id == 7 && _error.field == "identity" {
                return WorkerError.identityIsExist
            }
        }
        return nil
    }
    
    static func webApiError (form error: Swift.Error) -> Swift.Error? {
        if let error = error as? MoveApi.ApiError {
            return WorkerError.webApi(id: error.id!, field: error.field, msg: error.msg)
        }
        return nil
    }
    
    static func workerError (form error: Swift.Error) -> Swift.Error? {
        if let _error = WorkerError.accountNotFoundError(form: error) {
            return _error
        }
        if let _error = WorkerError.accountIsExistError(form: error){
            return _error
        }
        if let _error = WorkerError.passwordError(form: error) {
            return _error
        }
        if let _error = WorkerError.vcodeIsIncorrectError(form: error) {
            return _error
        }
        if let _error = WorkerError.identityIsExistError(form: error) {
            return _error
        }
        if let _error = WorkerError.webApiError(form: error) {
            return _error
        }
        return nil
    }
    
}
