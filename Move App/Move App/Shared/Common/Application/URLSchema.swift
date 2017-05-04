//
//  URLSchema.swift
//  Move App
//
//  Created by jiang.duan on 2017/4/12.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit


extension AppDelegate {
    
    /**
     *  当一个指定的URL资源打开时调用，iOS9之前
     *
     *  @param url               指定的url
     *  @param sourceApplication 请求打开应用的bundle ID
     */
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        handle(open: url, sourceApplication: sourceApplication)
        return true
    }
    
    /**
     *  当一个指定的URL资源打开时调用，iOS9之后
     *
     *  @param url     指定的url
     *  @param options 打开选项，其中通过UIApplicationOpenURLOptionsSourceApplicationKey获得sourceApplication
     */
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if #available(iOS 9.0, *) {
            let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
            handle(open: url, sourceApplication: sourceApplication)
        }
        return true
    }
    
    private func handle(open url: URL, sourceApplication: String?) {
        Logger.verbose("sourceApplication: \(sourceApplication)")
        Logger.verbose(url)
        
        guard
            let scheme = url.scheme, scheme.uppercased() == "TCLMOVE",
            let host = url.host, host.contains("alcatel-move.com"),
            //url.path == "/latam/lbs/v1.0",
            let sos = KidSate.SOSLbsModel(aURL: url) else {
            return
        }
        SOSService.shared.handle(sos)
    }

}

