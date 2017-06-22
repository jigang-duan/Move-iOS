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

class SafeZoneController: UIViewController {
    
    //internationalization
    @IBOutlet weak var safezoneTitleItem: UINavigationItem!

    
    @IBOutlet weak var safezoneQutlet: UIButton!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var introducelLabel: UILabel!
    @IBOutlet weak var emptyViewQutlet: UIView!
    
    var dataISexit: Bool = true
    var autopositioningBool: Bool?
    var adminBool: Bool? = false
    var autoAnswer: Bool?
    var savePower: Bool?
    var autopositioningBtn: SwitchButton?
    var disposeBag = DisposeBag()
    
    var fences: [KidSate.ElectronicFencea] = []
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.permissionsFun(adminbooll: adminBool!)
        
        self.tableview.estimatedRowHeight = 80.0
        self.tableview.contentInset = UIEdgeInsetsMake(-30, 0, 0, 0)
        
        safezoneQutlet.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.showAddSafeZoneVC()
            })
            .addDisposableTo(disposeBag)
       
       tableview.delegate = self
       tableview.dataSource = self
    
        tableview.register(R.nib.safezoneCell(), forCellReuseIdentifier: R.reuseIdentifier.safezonecell.identifier)
    }
    
    func reloadData(){
        //拉取数据
        LocationManager.share.fetchSafeZone()
            .bindNext { [weak self] in
                self?.fences = $0
                self?.tableview.reloadData()
            }
            .addDisposableTo(disposeBag)
    }
    
    func showAddSafeZoneVC() {
        
            
        if self.fences.count >= 5 {
            let alertController = UIAlertController(title: nil, message: "not more than 5 safe zone", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }else{

            if adminBool! {
                if !autopositioningBool!{
                    let alertController = UIAlertController(title: "Warning", message: "Auto-positioning is closed,the location infromation is not timely, for more accurate location information, please open Auto-positioning, it will consume more power", preferredStyle: .alert)
                    
                    let notOpen = UIAlertAction(title: "Not open", style: .cancel, handler: { (UIAlertAction) in
                        
                        self.showAddSafezoneV()
                    })
                    
                    let open = UIAlertAction(title: "Open Auto-positionning", style: .default, handler: { (UIAlertAction) in
                        WatchSettingsManager.share.updateSavepowerAndautoAnswer(self.autoAnswer!, savepower: self.savePower!, autoPosistion: true).subscribe({ (bool : Event<Bool>) in
                            
                            UserDefaults.standard.set(true, forKey: "autopositiBool")
                            UserDefaults.standard.synchronize()
                            
                        }).addDisposableTo(self.disposeBag)
                        self.autopositioningBtn?.isOn = true
                        self.autopositioningBool = true

                        self.showAddSafezoneV()
                        
                    })
                    alertController.addAction(notOpen)
                    alertController.addAction(open)
                    self.present(alertController, animated: true, completion: nil)
                }
                self.showAddSafezoneV()
  
            }else
            {
                self.showAddSafezoneV()
            }
            
        }
        

    }
    
    func showAddSafezoneV() {
        if let vc = R.storyboard.major.addSafeZoneVC() {
            vc.fences = self.fences
            vc.adminBool = self.adminBool
            self.navigationController?.show(vc, sender: nil)
        }
    }
    
    func permissionsFun(adminbooll: Bool) {
        introducelLabel.text = "Only master can edit safe zone"
        if adminbooll{
            introducelLabel.text = "When kid enter or leave the safe zone,warning will be sent to your app."
        }
        
        safezoneQutlet.isHidden = !adminbooll
    }

    
    func errorshow(message : String) {
        let alertController = UIAlertController(title: "Save Error", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension SafeZoneController: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableview.isHidden = false
        if self.fences.count == 0
        {
            self.tableview.isHidden = true
            let lable: UILabel = self.emptyViewQutlet.subviews[1] as! UILabel
            if self.adminBool!{
                
                lable.text = "No Safe zone here,tap \"+\" to add a safe zone"
                
            }else
            {
                lable.text = "No Safe zone here"
            }
        }
        
        
        return self.fences.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: R.reuseIdentifier.safezonecell.identifier, for: indexPath) as! SafezoneCell
        cell.model = self.fences[indexPath.row]
        cell.autopositioningBool = autopositioningBool
        cell.adminBool = adminBool
        cell.autoAnswer = autoAnswer
        cell.savePower = savePower
        cell.btn = autopositioningBtn
        cell.onOFFLabel.isHidden = adminBool!
        cell.switchOnOffQutiet.isHidden = !adminBool!
        if !adminBool!{
            cell.accessoryType = .disclosureIndicator
        }
        cell.vc = self
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
        if self.adminBool!{
            
            return .delete
            
        }
        else
        {
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let vc : AddSafeZoneVC = R.storyboard.major.addSafeZoneVC()  {
            vc.editFenceDataSounrce = self.fences[indexPath.row]
            var fence = self.fences
            fence.remove(at: indexPath.row)
            vc.fences = fence
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
                self?.tableview.reloadData()
                }.addDisposableTo(disposeBag)        
        }
     
    }
    
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return R.string.localizable.id_str_remove_alarm_title()
    }
}


