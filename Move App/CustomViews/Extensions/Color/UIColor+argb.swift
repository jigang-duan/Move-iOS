//
//  UIColor+Theme.swift
//  LinkApp
//
//  Created by Jiang Duan on 17/1/3.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit


func rgb(_ red: Int, _ green: Int, _ blue: Int) -> Int {
    return (blue | (green << 8) | (red << 16) | (0xFF << 24))
}

func argb(_ alpha: Int, _ red: Int, _ green: Int, _ blue: Int) -> Int {
    return (blue | (green << 8) | (red << 16) | (alpha << 24))
}

extension UIColor {
    
    convenience public init(r: UInt, g: UInt, b: UInt, a: UInt = 0xFF) {
        let argb = ((a & 0xFF) << 24) | ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF)
        self.init(argb: argb)
    }
    
    // ARGB
    convenience public init(argb: UInt) {
        let blue    = (CGFloat)((argb >>  0) & 0xFF) / 255.0
        let green   = (CGFloat)((argb >>  8) & 0xFF) / 255.0
        let red     = (CGFloat)((argb >> 16) & 0xFF) / 255.0
        let alpha   = (CGFloat)((argb >> 24) & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    // RGB
    convenience public init(rgb: Int) {
        let blue    = (CGFloat)((rgb >>  0) & 0xFF) / 255.0
        let green   = (CGFloat)((rgb >>  8) & 0xFF) / 255.0
        let red     = (CGFloat)((rgb >> 16) & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
}
