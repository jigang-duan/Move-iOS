//
//  SelectFamilyAndWatchVC.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/4/20.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit


class SelectFamilyAndWatchVC: UITableViewController {
    
    @IBOutlet weak var cellLab1: UILabel!
    @IBOutlet weak var cellLab2: UILabel!
    
    private func initializeI18N() {
        self.title = R.string.localizable.id_watch_contact()
        
        cellLab1.text = R.string.localizable.id_family_member()
        cellLab2.text = R.string.localizable.id_watch_friends()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeI18N()
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = R.segue.selectFamilyAndWatchVC.showFamilyMember(segue: segue)?.destination {
            vc.isMater = true
        }
    }
    
    
    
}
