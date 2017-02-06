//
//  Move_AppTests.swift
//  Move AppTests
//
//  Created by Jiang Duan on 17/1/19.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import XCTest
import RxTest
import RxBlocking
@testable import Move_App

class Move_AppTests: XCTestCase {
    
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
    
    func testLogger() {
        Logger.verbose("not so important")  // prio 1, VERBOSE in silver
        Logger.debug("something to debug")  // prio 2, DEBUG in green
        Logger.info("a nice information")   // prio 3, INFO in blue
        Logger.warning("oh no, that won’t be good")  // prio 4, WARNING in yellow
        Logger.error("ouch, an error did occur!")  // prio 5, ERROR in red
        
        // log anything!
        Logger.verbose(123)
        Logger.info(-123.45678)
        Logger.warning(Date())
        Logger.error(["I", "like", "logs!"])
        Logger.error(["name": "Mr Beaver", "address": "7 Beaver Lodge"])
        
        Logger.info(R.string.localizable.id_app_name())
    }
    
    func testRswift() {
        do {
            try R.validate()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testMap() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 4),
            completed(300)
            ])
        
        let res = scheduler.start { xs.map { $0 * 2 } }
        
        let correctEvents = [
            next(210, 0 * 2),
            next(220, 1 * 2),
            next(230, 2 * 2),
            next(240, 4 * 2),
            completed(300)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(res.events, correctEvents)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
