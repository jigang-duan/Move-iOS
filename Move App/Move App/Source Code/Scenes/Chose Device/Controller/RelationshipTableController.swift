//
//  RelationshipTableController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/14.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class RelationshipTableController: UITableViewController {
    
//    @IBOutlet weak var MotherCell: UITableViewCell!
//    @IBOutlet weak var FatherCell: UITableViewCell!
//    @IBOutlet weak var GrandmaCell: UITableViewCell!
//    @IBOutlet weak var GrandapaCell: UITableViewCell!
//    @IBOutlet weak var AntyCell: UITableViewCell!
//    @IBOutlet weak var UncleCell: UITableViewCell!
//    @IBOutlet weak var BrotherCell: UITableViewCell!
//    @IBOutlet weak var SisterCell: UITableViewCell!
//    @IBOutlet weak var OtherCell: UITableViewCell!
    
    @IBOutlet var cells: [UITableViewCell]!
    
    
    var phoneNumber: String?
    
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
        for cell in cells {
            cell.selectionStyle = UITableViewCellSelectionStyle.none
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for cell in cells {
            if cell == tableView.cellForRow(at: indexPath) {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            }else{
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
        }
    }

    
}
