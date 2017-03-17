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
    
    var cellHeart = Variable((flag: false, row: 0))
    
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
                selectedContact: selectedContact,
                cellHeartClick: cellHeart
            ),
            dependency:(
                deviceManager: DeviceManager.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
            )
        viewModel.cellDatas?.bindTo(viewModel.cellDatasVariable).addDisposableTo(disposeBag)
        
        viewModel.cellDatasVariable.asObservable()
            .bindTo(tableView.rx.items(cellIdentifier: R.reuseIdentifier.familyMemberCell.identifier, cellType: FamilyMemberTableViewCell.self)){ (row, element, cell) in
                cell.heartBun.setImage(element.isHeartOn ? R.image.member_heart_on() : R.image.member_heart_off(), for: .normal)
                cell.isHeartOn = element.isHeartOn
                
                cell.heartClick = {[weak cell] _ in
                    cell?.isHeartOn = !(cell?.isHeartOn)!
                    self.cellHeart.value = (flag: (cell?.isHeartOn)!, row: row)
                }
                
                cell.relationName.text = element.relation + (element.state.contains(.me) ? "(Me)":"")
                
                if element.state.contains(.master){
                    cell.detailLab.text = "Master"
                }
               
                let imgUrl = MoveApi.BaseURL + "/v1.0/fs/\(element.headUrl)"
                cell.headImgV.imageFromURL(imgUrl, placeholder:  R.image.member_btn_contact_nor()!)
            }
            .addDisposableTo(disposeBag)
    
        viewModel.heartResult?.drive(onNext: { res in
            res.drive(onNext: { r in
                switch r {
                case .failed(let message):
                    self.showMessage(message)
                default:
                    break
                }
            }).addDisposableTo(self.disposeBag)
            
        }).addDisposableTo(disposeBag)
        
        
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
    
    
    func showMessage(_ text: String) {
        let vc = UIAlertController.init(title: "提示", message: text, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        vc.addAction(action)
        self.present(vc, animated: true) {
            
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

}
