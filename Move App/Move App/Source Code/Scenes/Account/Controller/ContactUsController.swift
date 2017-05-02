//
//  ContactUsTableVC.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/4/13.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import SafariServices

class ContactUsController: UITableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let url = URL(string: "http://www.alcatel-mobile.com")!
            if #available(iOS 9.0, *) {
                let sVC = SFSafariViewController(url: url)
                self.present(sVC, animated: true, completion: nil)
            } else {
                DefaultWireframe.sharedInstance.open(url: url)
            }
        }
    }
    
}
