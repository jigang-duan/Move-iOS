//
//  OtherSettingsVCTableViewController.swift
//  Move App
//
//  Created by LX on 2017/4/14.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class OtherSettingsViewController: UITableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if (indexPath.row == 0) {
            let alert = UIAlertController(title: nil, message: "clean the cache!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Clean", style: .default) { _ in
                SynckeyEntity.clearMessages()
                _ = clearCachesFromDirectoryPath(path: NSTemporaryDirectory())
            })
            alert.addAction(UIAlertAction(title: "Cancle", style: .default))
            present(alert, animated: true, completion: nil)
        }
    }
}

fileprivate func clearCachesFromDirectoryPath(path: String) -> Bool {
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
