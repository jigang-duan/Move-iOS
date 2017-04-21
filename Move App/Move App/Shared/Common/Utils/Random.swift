//
//  Random.swift
//  Move App
//
//  Created by jiang.duan on 2017/4/20.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation

struct Random {
    
    static func numberStr(scope: Int) -> String {
        let source = "0123456789".characters.map { String($0) }
        return Array(0 ..< scope).map{ _ in Int(arc4random_uniform(UInt32(source.count))) }.map{ source[$0] }.reduce("") { $0 + $1 }
    }
    
    // MARK: 不重复的随机数
    
    /**
     * 区间表示 ==> [1, end]
     */
    static func number(end: Int) -> [Int] {
        var startArr = Array(1...end)
        var resultArr = Array(repeating: 0, count: end)
        for i in 0..<startArr.count {
            let currentCount = UInt32(startArr.count - i)
            let index = Int(arc4random_uniform(currentCount))
            resultArr[i] = startArr[index]
            startArr[index] = startArr[Int(currentCount) - 1]
        }
        return resultArr
    }
    
    /**
     *  半闭区间表示 ==> (start, end]
     */
    static func numberPro(start: Int, end: Int) -> [Int] {
        let scope = end - start
        var startArr = Array(1...scope)
        var resultArr = Array(repeating: 0, count: scope)
        for i in 0..<startArr.count {
            let currentCount = UInt32(startArr.count - i)
            let index = Int(arc4random_uniform(currentCount))
            resultArr[i] = startArr[index]
            startArr[index] = startArr[Int(currentCount) - 1]
        }
        return resultArr.map { $0 + start }
    }
}
