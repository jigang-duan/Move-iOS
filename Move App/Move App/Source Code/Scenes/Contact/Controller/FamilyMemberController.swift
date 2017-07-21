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
    @IBOutlet weak var tipLab: UILabel!
    @IBOutlet weak var emergencyTip: UILabel!
    @IBOutlet weak var qrCodeLab: UILabel!
    @IBOutlet weak var manualLab: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var popView: UIView!
    
    @IBOutlet weak var emergencyLab: UILabel!
    
    @IBOutlet weak var addBun: UIBarButtonItem!
    
    
    var isMater = false//是否是管理员
    
    private var viewModel: FamilyMemberViewModel!
    private var disposeBag = DisposeBag()
    private let enterCount = Variable(0)
    
    private var selectInfo: FamilyMemberDetailController.ContactDetailInfo?
    
    private var cellHeart = Variable((flag: false, row: 0))
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        enterCount.value += 1
        
        if isMater == true {
            WatchSettingsManager.share.fetchEmergencyNumbers()
                .subscribe(onNext: { [weak self] numbers in
                    self?.emergencyLab.text = numbers.joined(separator: ",")
                })
                .addDisposableTo(disposeBag)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        popView.isHidden = true
    }
    
    
    private func initializeI18N() {
        self.title = R.string.localizable.id_family_member()
        
        tipLab.text = R.string.localizable.id_family_member_prompt()
        emergencyTip.text = R.string.localizable.id_family_emergency_number()
        qrCodeLab.text = R.string.localizable.id_family_member_by_qr_code()
        manualLab.text = R.string.localizable.id_family_member_input_number()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeI18N()
        
        popView.isHidden = true
        
        if isMater == false {
            self.navigationItem.rightBarButtonItem = nil
            tableView.tableHeaderView = UIView()
        }
        
        
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
            .bindTo(tableView.rx.items(cellIdentifier: R.reuseIdentifier.familyMemberCell.identifier, cellType: FamilyMemberTableViewCell.self)){ [weak self] (row, element, cell) in
                cell.heartBun.setImage(element.isHeartOn ? R.image.member_heart_on() : R.image.member_heart_off(), for: .normal)
                cell.isHeartOn = element.isHeartOn
                
                if self?.isMater == true {
                    cell.heartClick = {[weak cell] _ in
                        cell?.isHeartOn = !(cell?.isHeartOn)!
                        self?.cellHeart.value = (flag: (cell?.isHeartOn)!, row: row)
                    }
                }
                
                cell.relationName.text = element.relation.description + (element.state.contains(.me) ? R.string.localizable.id_contact_me():"")
                
                if element.state.contains(.master){
                    cell.detailLab.text = R.string.localizable.id_master()
                }else{
                    cell.detailLab.text = ""
                }
                
                let imgUrl = URL(string: FSManager.imageUrl(with: element.headUrl))
                cell.headImgV.kf.setImage(with: imgUrl, placeholder: element.relation.image)
                cell.headImgV.layer.cornerRadius = 18
                cell.headImgV.layer.masksToBounds = true
            }
            .addDisposableTo(disposeBag)
    
        viewModel.heartResult?.drive(onNext: { res in
            res.drive(onNext: { [weak self] r in
                switch r {
                case .failed(let message):
                    self?.showMessage(message)
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
        
        viewModel.cellDatasVariable.asObservable()
            .map{ $0.count < 10 }
            .bindTo(addBun.rx.isEnabled)
            .addDisposableTo(disposeBag)
    }
    
    
    @IBAction func showPopView(_ sender: Any) {
        UIView.animate(withDuration: 0.3) { [weak self] _ in
            self?.popView.isHidden = !(self?.popView.isHidden ?? false)
            self?.popView.layoutIfNeeded()
        }
    }
    
    
    func showMessage(_ text: String) {
        let vc = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: R.string.localizable.id_ok(), style: .cancel)
        vc.addAction(action)
        self.present(vc, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = R.segue.familyMemberController.showFamilyMemberDetail(segue: segue)?.destination {
            vc.info = selectInfo
            vc.masterInfo = self.viewModel.contacts?.filter({$0.contactInfo?.admin == true})[0].contactInfo
        }
        
        if let vc = R.segue.familyMemberController.showEmergency(segue: segue)?.destination {
            vc.numbers = emergencyLab.text ?? ""
        }
        
    }
    
}

