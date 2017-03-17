//
//  AppDelegate+OAuthSwift.swift
//  Move App
//
//  Created by jiang.duan on 2017/3/17.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import OAuthSwift

// MARK: ApplicationDelegate

extension AppDelegate {
        
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        applicationHandle(url: url)
        return true
    }
        
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        applicationHandle(url: url)
        return true
    }
    
    // MARK: handle callback url
    private func applicationHandle(url: URL) {
        if (url.host == "oauth-callback") {
            OAuthSwift.handle(url: url)
        } else {
            // Google provider is the only one wuth your.bundle.id url schema.
            OAuthSwift.handle(url: url)
        }
    }
}
