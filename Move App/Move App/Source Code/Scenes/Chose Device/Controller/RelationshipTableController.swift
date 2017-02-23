//
//  RelationshipTableController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/14.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class RelationshipTableController: UITableViewController {
    
    @IBOutlet weak var MotherCell: UITableViewCell!
    @IBOutlet weak var FatherCell: UITableViewCell!
    @IBOutlet weak var GrandmaCell: UITableViewCell!
    @IBOutlet weak var GrandapaCell: UITableViewCell!
    @IBOutlet weak var AntyCell: UITableViewCell!
    @IBOutlet weak var UncleCell: UITableViewCell!
    @IBOutlet weak var BrotherCell: UITableViewCell!
    @IBOutlet weak var SisterCell: UITableViewCell!
    @IBOutlet weak var OtherCell: UITableViewCell!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.BaseSetting()
    }
    private func BaseSetting(){
        
        tableView.contentInset = UIEdgeInsetsMake(-34, 0, 0, 0)
        MotherCell.selectionStyle = UITableViewCellSelectionStyle.none
        FatherCell.selectionStyle = UITableViewCellSelectionStyle.none
        GrandmaCell.selectionStyle = UITableViewCellSelectionStyle.none
        GrandapaCell.selectionStyle = UITableViewCellSelectionStyle.none
        AntyCell.selectionStyle = UITableViewCellSelectionStyle.none
        UncleCell.selectionStyle = UITableViewCellSelectionStyle.none
        BrotherCell.selectionStyle = UITableViewCellSelectionStyle.none
        SisterCell.selectionStyle = UITableViewCellSelectionStyle.none
        OtherCell.selectionStyle = UITableViewCellSelectionStyle.none
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        MotherCell.accessoryType = UITableViewCellAccessoryType.none
        FatherCell.accessoryType = UITableViewCellAccessoryType.none
        GrandmaCell.accessoryType = UITableViewCellAccessoryType.none
        GrandapaCell.accessoryType = UITableViewCellAccessoryType.none
        AntyCell.accessoryType = UITableViewCellAccessoryType.none
        UncleCell.accessoryType = UITableViewCellAccessoryType.none
        BrotherCell.accessoryType = UITableViewCellAccessoryType.none
        SisterCell.accessoryType = UITableViewCellAccessoryType.none
        OtherCell.accessoryType = UITableViewCellAccessoryType.none
        
        
        if indexPath.row == 0 {
            
            MotherCell.accessoryType = UITableViewCellAccessoryType.checkmark
            
        }else if indexPath.row == 1
        {
            FatherCell.accessoryType = UITableViewCellAccessoryType.checkmark
            
        }else if indexPath.row == 2
        {
            GrandmaCell.accessoryType = UITableViewCellAccessoryType.checkmark
            
        }else if indexPath.row == 3
        {
            GrandapaCell.accessoryType = UITableViewCellAccessoryType.checkmark
            
        }else if indexPath.row == 4
        {
            AntyCell.accessoryType = UITableViewCellAccessoryType.checkmark
        }else if indexPath.row == 5
        {
            UncleCell.accessoryType = UITableViewCellAccessoryType.checkmark}
        else if indexPath.row == 6
        {
             BrotherCell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        else if indexPath.row == 7
        {
             SisterCell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        else if indexPath.row == 8
        {
             OtherCell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        
    }

    
}
