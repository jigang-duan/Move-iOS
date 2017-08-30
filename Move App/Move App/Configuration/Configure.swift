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
        static let isDebugJSON = true
        static let isHTTPS = true

        static let testHost = "10.129.60.82:9092"
        static let Host = "139.196.178.104"
        static let domainHost = "www.alcatel-move.com"
        static let apiPath = ""
        
        // Base
        static let BaseURL: String = {
            let host = domainHost
            if Configure.App.isHTTPS {
                return "https://" + host + apiPath
            }
            else {
                return "http://" + host + apiPath
            }
        }()
        
        static let ApiKey = "vEWZapEpW5OezzEs5Su44xAbCiy9-arCJz7eoLJfjac2h1r4VF0"
        
        // Scenes
        static let LoadDataOfPeriod = 30.0
        
        //UI Debug
        static let isDebugUI = false
        
        static let canBugly = false
    }
    
    //
    // MARK: - Logger
    struct Logger {
        
        static let toFile = true
        
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
