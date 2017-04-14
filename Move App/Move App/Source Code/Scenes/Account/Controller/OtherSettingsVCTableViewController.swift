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
    
        if(indexPath.row == 0)
        {
            SynckeyEntity.clearMessages()
            let _ = clearCachesFromDirectoryPath(path: NSTemporaryDirectory())
            let alertController = UIAlertController(title: "系统提示",
                                                    message: "缓冲删除成功", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "确定", style: .default, handler: {
                action in
               
            })
    
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
    }
        
    }
   
    func clearCachesFromDirectoryPath(path: String) -> Bool {
        let manage = FileManager.default
        if !manage.fileExists(atPath: path)
        {}
        let childFilePath = manage.subpaths(atPath: path)
        for path_1 in childFilePath!{
            let fileAbsoluePath = path + "/" + path_1
            let manage = FileManager.default
            do {
                try manage.removeItem(atPath: fileAbsoluePath)
            } catch {
                
            }
        }
        
        return true
    
    }
}

