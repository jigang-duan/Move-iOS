//
//  OtherSettingsVCTableViewController.swift
//  Move App
//
//  Created by LX on 2017/4/14.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class OtherSettingsViewController: UITableViewController {
    
    @IBOutlet weak var cellLab1: UILabel!
    @IBOutlet weak var cellLab2: UILabel!
    @IBOutlet weak var cellLab3: UILabel!
    @IBOutlet weak var cellLab4: UILabel!
    
    
    private func initializeI18N() {
        self.title = R.string.localizable.id_action_settings()
        
        cellLab1.text = R.string.localizable.id_cache_clean()
        cellLab2.text = R.string.localizable.id_contact_us()
        cellLab3.text = R.string.localizable.id_help()
        cellLab4.text = R.string.localizable.id_about()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeI18N()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let alert = UIAlertController(title: nil, message: R.string.localizable.id_cache_clean(), preferredStyle: .alert)
            let action = UIAlertAction(title: R.string.localizable.id_confirm(), style: .default) { _ in
                SynckeyEntity.clearMessages()
                _ = clearCache(path: NSTemporaryDirectory())
            }
            alert.addAction(action)
            alert.addAction(UIAlertAction(title: R.string.localizable.id_cancel(), style: .default))
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
