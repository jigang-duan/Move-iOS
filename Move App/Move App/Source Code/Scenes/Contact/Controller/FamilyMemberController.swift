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
    
    
    var viewModel: FamilyMemberViewModel!
    var disposeBag = DisposeBag()
    let enterCount = Variable(0)
    
    var selectInfo: FamilyMemberDetailController.ContactDetailInfo?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        enterCount.value += 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        popView.isHidden = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popView.isHidden = true
        
        tableView.rx
            .setDelegate(self)
            .addDisposableTo(disposeBag)
        
        tableView.register(R.nib.familyMemberTableViewCell)
        
    
        let selectedContact = tableView.rx.itemSelected.asDriver()
            .map({ self.viewModel.contacts?[$0.row] })
            .filterNil()
        
        viewModel = FamilyMemberViewModel(
            input: (
                enterCount: enterCount.asObservable(),
                selectedContact: selectedContact
            ),
            dependency:(
                deviceManager: DeviceManager.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
            )
            
        
        viewModel.cellDatas?
            .bindTo(tableView.rx.items(cellIdentifier: R.reuseIdentifier.familyMemberCell.identifier, cellType: FamilyMemberTableViewCell.self)){ (row, element, cell) in
                cell.heartImgV.image = element.isHeartOn ? R.image.member_heart_on() : R.image.member_heart_off()
                
                var text = element.relation
                if element.state.contains(.me){
                    text = text + "(me)"
                }
                if element.state.contains(.master){
                    text = text + "(master)"
                }
                cell.relationName.text = text
                
                let imgUrl = MoveApi.BaseURL + "/v1.0/fs/\(element.headUrl)"
                cell.headImgV.imageFromURL(imgUrl, placeholder:  R.image.member_btn_contact_nor()!)
            }
            .addDisposableTo(disposeBag)
    
        
        viewModel.selected
            .drive(onNext: { [weak self] info  in
                self?.selectInfo = info
                self?.performSegue(withIdentifier: R.segue.familyMemberController.showFamilyMemberDetail, sender: nil)
            })
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
            vc.info = selectInfo
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

}
