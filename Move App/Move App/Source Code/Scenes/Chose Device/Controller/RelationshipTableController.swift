//
//  RelationshipTableController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/14.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift

class RelationshipTableController: UITableViewController {
    
    var relationBlock: ((Int) -> Void)?
    
    @IBOutlet var cells: [UITableViewCell]!
    
    var deviceAddInfo: DeviceBindInfo?
    
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
        
        if self.relationBlock != nil {
            self.relationBlock!(indexPath.row)
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
        
        deviceAddInfo?.identity = Relation.transformToEnum(input: indexPath.row + 1)
        
        if deviceAddInfo?.isMaster == true {
            self.performSegue(withIdentifier: R.segue.relationshipTableController.showKidInformation, sender: nil)
        }else{
            _ = DeviceManager.shared.joinGroup(joinInfo: deviceAddInfo!).subscribe({ (event) in
                switch event{
                case .next(let value):
                    print(value)
                case .completed:
                    _ = self.navigationController?.popToRootViewController(animated: true)
                case .error(let error):
                    print(error)
                }
            })
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sg = R.segue.relationshipTableController.showKidInformation(segue: segue) {
            sg.destination.deviceAddInfo = self.deviceAddInfo
            sg.destination.isForSetting = false
        }
    }
    
}


















