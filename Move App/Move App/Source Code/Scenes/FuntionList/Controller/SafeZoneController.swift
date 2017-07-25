//
//  SafeZoneController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/20.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import CustomViews
import DZNEmptyDataSet

class SafeZoneController: UIViewController {
    
    //internationalization
    
    var autoPositionBlock: ((Bool) -> ())?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var introducelLabel: UILabel!
    
    var dataISexit: Bool = true
    var autopositioningBool: Bool?
    var adminBool: Bool? = false
    
    var autopositioningBtn: SwitchButton?
    var disposeBag = DisposeBag()
    
    var fences: [KidSate.ElectronicFence] = []
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = R.string.localizable.id_safe_zone()
        self.permissionsFun(adminbool: adminBool!)
        
        tableView.emptyDataSetSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }
    
    func reloadData(){
        //拉取数据
        LocationManager.share.fetchSafeZone()
            .bindNext { [weak self] in
                self?.fences = $0
                self?.tableView.reloadData()
            }
            .addDisposableTo(disposeBag)
    }
    
    
    @IBAction func addClick(_ sender: Any) {
        
        if self.fences.count >= 5 {
            let alertController = UIAlertController(title: nil, message: R.string.localizable.id_only_safe_zone(), preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: R.string.localizable.id_ok(), style: .default, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }else{
//            if autopositioningBool == false {
//                let alertController = UIAlertController(title: nil, message: R.string.localizable.id_safe_zone_admin(), preferredStyle: .alert)
//                
//                let notOpen = UIAlertAction(title: R.string.localizable.id_cancel(), style: .default) { _ in
//                    self.showAddSafezoneVC()
//                }
//                let open = UIAlertAction(title: R.string.localizable.id_safe_zone_admin_right(), style: .default) { _ in
//                    WatchSettingsManager.share.updateAutoPosition(true)
//                        .subscribe({ (bool : Event<Bool>) in
//                            
//                        })
//                        .addDisposableTo(self.disposeBag)
//                    
//                    if self.autoPositionBlock != nil {
//                        self.autoPositionBlock!(true)
//                    }
//                    
//                    self.autopositioningBtn?.isOn = true
//                    self.autopositioningBool = true
//
//                    self.showAddSafezoneVC()
//                }
//                alertController.addAction(notOpen)
//                alertController.addAction(open)
//                self.present(alertController, animated: true)
//            }else{
                self.autoPositionBlock!(autopositioningBool!)
                self.showAddSafezoneVC()
//            }
        }
    }
    
    func showAddSafezoneVC() {
        if let vc = R.storyboard.major.addSafeZoneVC() {
            
            vc.fences = self.fences
            vc.adminBool = self.adminBool
            self.navigationController?.show(vc, sender: nil)
        }
    }
    
    func permissionsFun(adminbool: Bool) {
        introducelLabel.text = R.string.localizable.id_safezone_prompt_not_admin()
        if adminbool {
            introducelLabel.text = R.string.localizable.id_safezone_prompt()
        }else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    
}

extension SafeZoneController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fences.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        
        var model = self.fences[indexPath.row]
        
        cell?.textLabel?.text = model.name
        cell?.detailTextLabel?.text = model.location?.address
        
        if adminBool == false {
            let lab = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 20))
            lab.textColor = UIColor.lightGray
            lab.textAlignment = .right
            if model.active == true {
                lab.text = R.string.localizable.id_on()
            }else{
                lab.text = R.string.localizable.id_off()
            }
            cell?.accessoryView = lab
        }else{
            let bun = SwitchButton(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
            bun.onImage = R.image.general_btn_on()!
            bun.offImage = R.image.general_btn_off()!
            
            bun.isOn = model.active ?? false
            cell?.accessoryView = bun
         
            bun.closureSwitch = { [unowned self] isOn in
                if isOn{
                    if self.autopositioningBool == false {
                        let alertController = UIAlertController(title: nil, message: R.string.localizable.id_safe_zone_admin(), preferredStyle: .alert)
                        
                        let notOpen = UIAlertAction(title: R.string.localizable.id_cancel(), style: .default)
                        
                        let open = UIAlertAction(title: R.string.localizable.id_safe_zone_admin_right(), style: .default) { _ in
                            //发起请求打开open auto-positioning按钮
                            WatchSettingsManager.share.updateAutoPosition(true)
                                .subscribe(onNext: { (flag) in
                                
                                })
                                .addDisposableTo(self.disposeBag)
                            if self.autoPositionBlock != nil {
                                self.autoPositionBlock!(true)
                            }
                        }
                        alertController.addAction(notOpen)
                        alertController.addAction(open)
                        
                        self.present(alertController, animated: true)
                    }
                }
                
                model.active = isOn
                
                let fenceloc = MoveApi.Fencelocation(lat: model.location?.location?.latitude, lng: model.location?.location?.longitude, addr: model.location?.address)
                let fenceinfo = MoveApi.FenceInfo(id: model.ids, name: model.name, location: fenceloc, radius: model.radius, active: model.active)
                let fencereq = MoveApi.FenceReq(fence : fenceinfo)
                
                MoveApi.ElectronicFence.settingFence(fenceId : (model.ids)!, fenceReq: fencereq)
                    .subscribe(onNext: {_ in
                        
                    })
                    .addDisposableTo(self.disposeBag)
            }

        }
        
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if self.adminBool!{
            return .delete
        }else{
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = R.storyboard.major.addSafeZoneVC()  {
            //让addsafe控制器 获取修改的值
            vc.editFenceDataSounrce = self.fences[indexPath.row]
            vc.fences = self.fences
            //删除自己
            vc.fences.remove(at: indexPath.row)
            vc.adminBool = self.adminBool
            self.navigationController?.show(vc, sender: nil)
        }
    }
    
    //删除数据源数据
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //删除
            LocationManager.share.delectSafeZone(self.fences[indexPath.row].ids ?? "")
                .bindNext { [weak self] in
                print($0)
                self?.fences.remove(at: indexPath.row)
//                self.tableview.deleteRows(at: [indexPath], with: .top)
                self?.tableView.reloadData()
                }.addDisposableTo(disposeBag)        
        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return R.string.localizable.id_str_remove_alarm_title()
    }
}


extension SafeZoneController: DZNEmptyDataSetSource {
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return R.image.safe_zone_empty()!
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var text = ""
        if self.adminBool == false {
            text = R.string.localizable.id_no_safe_zone_not_admin()
        }else{
            text = R.string.localizable.id_no_safe_zone()
        }
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 18.0),
                          NSForegroundColorAttributeName: UIColor.lightGray]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
}

