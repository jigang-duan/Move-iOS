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
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notify:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notify:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = R.string.localizable.id_title()
        otherTf.placeholder = R.string.localizable.id_other()
        
        
        tableView.delegate = self
        
        otherBadge.isHidden = true
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sg = R.segue.relationshipTableController.showKidInformation(segue: segue) {
            sg.destination.addInfoVariable.value = self.deviceAddInfo!
            sg.destination.isForSetting = false
        }
    }
    
    func showMessage(_ text: String) {
        let vc = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: R.string.localizable.id_ok(), style: .cancel)
        vc.addAction(action)
        self.present(vc, animated: true)
    }
    
    @IBAction func otherClick(_ sender: Any) {
        otherTf.becomeFirstResponder()
        otherBadge.isHidden = false
        
        
        self.clearCellSelected()
    }
    
    
    func keyboardWillShow(notify: Notification) {
        let frame = notify.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect
        
        let screenH = UIScreen.main.bounds.size.height
        
        var ff = self.tableView.frame
        ff.size.height = screenH - 64 - (frame?.size.height)! - 10
        self.tableView.frame = ff
        
        self.tableView.scrollToRow(at: IndexPath(row: self.identities.count - 1 , section: 0), at: UITableViewScrollPosition.bottom, animated: false)
    }
    
    
    func keyboardWillHide(notify: Notification) {
        let duration = notify.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval
        
        let screenH = UIScreen.main.bounds.size.height
        
        UIView.animate(withDuration: duration!) {[weak self] in
            var ff = self?.tableView.frame
            ff?.size.height = screenH - 64
            self?.tableView.frame = ff!
        }
    }
    
    
    
    func confirmSelectRelation() {
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
                    .subscribe(onNext: {_ in
                        _ = Distribution.shared.backToMainMap()
                    }, onError: { er in
                        if let msg = errorRecover(er) {
                            self.showMessage(msg)
                        }
                    })
                    .addDisposableTo(disposeBag)
            }

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
            selectedRelation = Relation.other(value: R.string.localizable.id_other())
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.confirmSelectRelation()
        return true
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
        
        self.confirmSelectRelation()
    }


}




fileprivate func errorRecover(_ error: Error) -> String? {
    guard let _error = error as?  WorkerError else {
        return nil
    }
    
    if WorkerError.webApi(id: 7, field: "uid", msg: "Exists") == _error {
        return R.string.localizable.id_watch_existed()
    }
    
    if WorkerError.webApi(id: 7, field: "phone", msg: "Exists") == _error {
        return R.string.localizable.id_phone_error_add()
    }
    
    let msg = WorkerError.apiErrorTransform(from: _error)
    return msg
}







