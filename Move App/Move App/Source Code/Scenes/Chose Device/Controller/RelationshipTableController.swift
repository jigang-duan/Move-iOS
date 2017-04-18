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
    
    var disposeBag = DisposeBag()
    
    
    
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
        
        if indexPath.row < 10 {
            deviceAddInfo?.identity = Relation(input: String(indexPath.row + 1))
        }else{
            deviceAddInfo?.identity = Relation(input: "Other")
        }
        
        
        
        if deviceAddInfo?.isMaster == true {
            self.performSegue(withIdentifier: R.segue.relationshipTableController.showKidInformation, sender: nil)
        }else{
            DeviceManager.shared.joinGroup(joinInfo: deviceAddInfo!)
                .subscribe(onNext: {[weak self] flag in
                    _ = self?.navigationController?.popToRootViewController(animated: true)
                }, onError: { er in
                    print(er)
                    if let _error = er as? WorkerError {
                        let msg = WorkerError.apiErrorTransform(from: _error)
                        self.showMessage(msg)
                    }
                })
                .addDisposableTo(disposeBag)
        }
    }
    
    func showMessage(_ text: String) {
        let vc = UIAlertController(title: "提示", message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        vc.addAction(action)
        self.present(vc, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sg = R.segue.relationshipTableController.showKidInformation(segue: segue) {
            sg.destination.addInfoVariable.value = self.deviceAddInfo!
            sg.destination.isForSetting = false
        }
    }
    
}


















