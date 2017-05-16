//
//  OtherSettingsVCTableViewController.swift
//  Move App
//
//  Created by LX on 2017/4/14.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class OtherSettingsViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let alert = UIAlertController(title: nil, message: "clean the cache!", preferredStyle: .alert)
            let action = UIAlertAction(title: "Clean", style: .default) { _ in
                SynckeyEntity.clearMessages()
                _ = clearCache(path: NSTemporaryDirectory())
            }
            alert.addAction(action)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default))
            present(alert, animated: true, completion: nil)
        }
    }
}

fileprivate func clearCache(path: String) -> Bool {
    let manage = FileManager.default
    guard manage.fileExists(atPath: path) else {
        return false
    }
    
    guard let childFilePath = manage.subpaths(atPath: path) else {
        return false
    }
    
    for child in childFilePath {
        let fileAbsoluePath = path + "/" + child
        try? manage.removeItem(atPath: fileAbsoluePath)
    }
    
    return true
}
