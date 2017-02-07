//
//  MoveApiTests.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/7.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import XCTest
import RxTest
import RxBlocking
import Moya
@testable import Move_App

class MoveApiTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testAccountApi()  {
        
        let accountName = RandomString.sharedInstance.getRandomStringOfLength(length: 13)
        guard let registered = try? MoveApi.Account.isRegistered(account: accountName)
            .toBlocking()
            .last() else {
            
            XCTFail()
            return
        }
        XCTAssertEqual(registered?.isRegistered, false)
        
        if let _ = try? MoveApi.Account.logout().do(onError: {
            Logger.error($0)
            guard let error = $0 as? MoveApi.ApiError else {
                XCTFail()
                return
            }
            XCTAssertEqual(error.id, 11)
            XCTAssertEqual(error.field, "access_token")
            XCTAssertEqual(error.msg, "Forbidden")
        }).toBlocking().last() {
            XCTFail()
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

/// 随机字符串生成
class RandomString {
    let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    
    /**
     生成随机字符串,
     
     - parameter length: 生成的字符串的长度
     
     - returns: 随机生成的字符串
     */
    func getRandomStringOfLength(length: Int) -> String {
        var ranStr = ""
        for _ in 0..<length {
            let index = Int(arc4random_uniform(UInt32(characters.characters.count)))
            ranStr.append(characters[characters.index(characters.startIndex, offsetBy: index)])
        }
        return ranStr
        
    }
    
    
    private init() {
        
    }
    static let sharedInstance = RandomString()
}
