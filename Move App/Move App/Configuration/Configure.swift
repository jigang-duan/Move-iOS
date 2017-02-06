//
//  Configure.swift
//  LinkApp
//
//  Created by Jiang Duan on 17/1/3.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation

struct Configure {
    
    
    // APPLICATION
    struct App {
        
        // Main
        static let isDebugJSON = false
        static let isHTTPS = false

        static let testHost = "10.129.60.82:9092"
        static let Host = "xx.xx.xx.xx"
        static let apiPath = ""
        
        // Base
        static let BaseURL: String = {
            let host = testHost
            if Configure.App.isHTTPS {
                return "https://" + host + apiPath
            }
            else {
                return "http://" + host + apiPath
            }
        }()
    }
    
    //
    // MARK: - Logger
    struct Logger {
        
        static let toFile = false
        
        static let toSlack = false
        
        // Slack Report
        struct Slack {
            
            // Base
            static let Token = "your.token.slack"
            static let ErrorChannel = "name.error.slack.channel"
            static let ResponseChannel = "name.response.slack.channel"
            
            
            // Webhook integration
            static let ErrorChannel_Webhook = "webhook.error.channel"
            static let ResponseChannel_Webhook = "webhook.response.channel"
        }
    }
    
}
