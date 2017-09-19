//
//  String+Specified.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/9/15.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation

extension String {

    var specifiedText: String {
        get {
        #if Tag_ALCATEL
            var str = self.replacingOccurrences(of: "TCLMOVE", with: "Family watch")
            str = str.replacingOccurrences(of: "TCLMove", with: "Family watch")
            str = str.replacingOccurrences(of: "tclmove", with: "Family watch")
            str = str.replacingOccurrences(of: "TclMove", with: "Family watch")
            return str
        #else
            return self
        #endif
        }
    }
    

}
