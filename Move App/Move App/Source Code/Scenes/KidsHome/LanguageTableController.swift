//
//  LanguageTableController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/22.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class LanguageTableController: UITableViewController {

    @IBOutlet weak var oneCell: UITableViewCell!
    @IBOutlet weak var twoCell: UITableViewCell!
    @IBOutlet weak var threeCell: UITableViewCell!
    @IBOutlet weak var fourCell: UITableViewCell!
    @IBOutlet weak var fiveCel: UITableViewCell!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       self.BaseSetting()
    }

    private func BaseSetting(){

        tableView.contentInset = UIEdgeInsetsMake(-34, 0, 0, 0)
        oneCell.selectionStyle = UITableViewCellSelectionStyle.none
        twoCell.selectionStyle = UITableViewCellSelectionStyle.none
        threeCell.selectionStyle = UITableViewCellSelectionStyle.none
        fourCell.selectionStyle = UITableViewCellSelectionStyle.none
        fiveCel.selectionStyle = UITableViewCellSelectionStyle.none
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        oneCell.accessoryType = UITableViewCellAccessoryType.none
        twoCell.accessoryType = UITableViewCellAccessoryType.none
        threeCell.accessoryType = UITableViewCellAccessoryType.none
        fourCell.accessoryType = UITableViewCellAccessoryType.none
        fiveCel.accessoryType = UITableViewCellAccessoryType.none


        
        if indexPath.row == 0 {
            
            oneCell.accessoryType = UITableViewCellAccessoryType.checkmark
            
        }else if indexPath.row == 1
        {
            twoCell.accessoryType = UITableViewCellAccessoryType.checkmark
            
        }else if indexPath.row == 2
        {
             threeCell.accessoryType = UITableViewCellAccessoryType.checkmark
            
        }else if indexPath.row == 3
        {
             fourCell.accessoryType = UITableViewCellAccessoryType.checkmark
            
        }else if indexPath.row == 4
        {
            fiveCel.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        
    }
        
        
}
    
    


