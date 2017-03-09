//
//  FamilyMemberController.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/7.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class FamilyMemberController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var popView: UIView!
    
    var items: Observable<[FamilyMemberCellData]>?
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popView.isHidden = true
        
        tableView.rx
            .setDelegate(self)
            .addDisposableTo(disposeBag)
        
        tableView.register(R.nib.familyMemberTableViewCell)
        
        items =  Observable.just([FamilyMemberCellData(headUrl: "", isHeartOn: true, relation: "5")])
    
        items?
            .bindTo(tableView.rx.items(cellIdentifier: R.reuseIdentifier.familyMemberCell.identifier, cellType: FamilyMemberTableViewCell.self)){ (row, element, cell) in
                cell.heartImgV.image = element.isHeartOn ? R.image.member_heart_on() : R.image.member_heart_off()
                cell.relationName.text = element.relation
                cell.heartImgV.imageFromURL(element.headUrl!, placeholder:  R.image.member_btn_contact_nor()!)
            }
            .addDisposableTo(disposeBag)
    }
    
    
    @IBAction func showPopView(_ sender: Any) {
        UIView.animate(withDuration: 0.3) { 
            self.popView.isHidden = !(self.popView.isHidden)
            self.popView.layoutIfNeeded()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = R.segue.familyMemberController.showFamilyMemberDetail(segue: segue)?.destination {
            
        }
        
    }
    
}


extension FamilyMemberController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: R.segue.familyMemberController.showFamilyMemberDetail, sender: nil)
        let cell = tableView.cellForRow(at: indexPath)
        cell?.selectionStyle = .none
    }

}
