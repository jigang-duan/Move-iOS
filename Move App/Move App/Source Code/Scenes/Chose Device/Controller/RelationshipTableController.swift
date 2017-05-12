//
//  RelationshipTableController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/14.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RelationshipTableController: UIViewController {
    
    var relationBlock: ((Relation) -> ())?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var otherTf: UITextField!
    @IBOutlet weak var otherBadge: UIImageView!
    
    var deviceAddInfo: DeviceBindInfo?
    
    var disposeBag = DisposeBag()
    
    fileprivate let identities = [R.string.localizable.id_mother(),
                            R.string.localizable.id_father(),
                            R.string.localizable.id_grandpa(),
                            R.string.localizable.id_grandma(),
                            R.string.localizable.id_uncle(),
                            R.string.localizable.id_aunt(),
                            R.string.localizable.id_brother(),
                            R.string.localizable.id_sister()]
    
    fileprivate let headImages = [R.image.relationship_ic_mun(),
                              R.image.relationship_ic_dad(),
                              R.image.relationship_ic_grandpa(),
                              R.image.relationship_ic_grandma(),
                              R.image.relationship_ic_uncle(),
                              R.image.relationship_ic_aunt(),
                              R.image.relationship_ic_brother(),
                              R.image.relationship_ic_sister()]
    
    
    fileprivate var selectedRelation: Relation?
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        otherBadge.isHidden = true
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sg = R.segue.relationshipTableController.showKidInformation(segue: segue) {
            sg.destination.addInfoVariable.value = self.deviceAddInfo!
            sg.destination.isForSetting = false
        }
    }
    
    
    @IBAction func otherClick(_ sender: Any) {
        otherTf.becomeFirstResponder()
        otherBadge.isHidden = false
        
        self.clearCellSelected()
    }
    
    @IBAction func nextClick(_ sender: Any) {
        otherTf.resignFirstResponder()
        
        if let identity = selectedRelation {
            
            if self.relationBlock != nil {
                self.relationBlock!(identity)
                _ = self.navigationController?.popViewController(animated: true)
                return
            }
            
            deviceAddInfo?.identity = identity
            
            if deviceAddInfo?.isMaster == true {
                self.performSegue(withIdentifier: R.segue.relationshipTableController.showKidInformation, sender: nil)
            }else{
                DeviceManager.shared.joinGroup(joinInfo: deviceAddInfo!)
                    .subscribe(onNext: {[weak self] flag in
                        _ = self?.navigationController?.popToRootViewController(animated: true)
                    })
                    .addDisposableTo(disposeBag)
            }

        }else{
            showAlert("no relation selected")
        }
        
    }
    
    
    func clearCellSelected() {
        for i in 0..<identities.count {
            let index = IndexPath(row: i, section: 0)
            let cell = tableView.cellForRow(at: index)
            tableView.deselectRow(at: index, animated: true)
            cell?.accessoryType = .none
        }
    }
    
    
}

extension RelationshipTableController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        otherBadge.isHidden = false
        self.clearCellSelected()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, text.characters.count > 0 {
            selectedRelation = Relation.other(value: text)
        }else{
            selectedRelation = Relation.other(value: "Other")
        }
    }
    
}



extension RelationshipTableController: UITableViewDelegate, UITableViewDataSource {


    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return identities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        cell?.selectionStyle = .none
        
        cell?.imageView?.image = headImages[indexPath.row]
        cell?.textLabel?.text = identities[indexPath.row]
        
        return cell!
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        otherTf.resignFirstResponder()
        otherBadge.isHidden = true
        
        self.clearCellSelected()
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        
        selectedRelation = Relation(input: String(indexPath.row + 1))
    }


}











