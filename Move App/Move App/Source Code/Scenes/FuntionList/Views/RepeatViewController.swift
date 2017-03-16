//
//  RepeatViewController.swift
//  Move App
//
//  Created by LX on 2017/3/9.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit



class RepeatViewController: UITableViewController {
     //internationalization
    @IBOutlet weak var NeverLabel: UILabel!
    @IBOutlet weak var everydayLabel: UILabel!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var everymonthLabel: UILabel!
    

    @IBOutlet weak var nevercell: UITableViewCell!
    @IBOutlet weak var everydaycell: UITableViewCell!
    @IBOutlet weak var everyweekcell: UITableViewCell!
    @IBOutlet weak var everymonthcell: UITableViewCell!
    
     var repeatBlock: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
    }

}

extension RepeatViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        nevercell?.accessoryType = .none
        everydaycell?.accessoryType = .none
        everyweekcell?.accessoryType = .none
        everymonthcell?.accessoryType = .none
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
//        self.delegate?.selectedRepeat!((cell?.textLabel?.text)!)
        self.repeatBlock!((cell?.textLabel?.text)!)
        
      _ = self.navigationController?.popViewController(animated: true)
        
    }

}
