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
import DZNEmptyDataSet

class SafeZoneController: UIViewController {
    
    //internationalization
    @IBOutlet weak var safezoneTitleItem: UINavigationItem!

    
    @IBOutlet weak var safezoneQutlet: UIButton!
    @IBOutlet weak var tableview: UITableView!
    var dataISexit: Bool = true
    var autopositioningBool: Bool?
    var disposeBag = DisposeBag()
    
    var fences: [KidSate.ElectronicFencea] = []
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.contentInset = UIEdgeInsetsMake(-30, 0, 0, 0)
        tableview.emptyDataSetSource = self
        
        safezoneQutlet.rx.tap
            .asDriver()
            .drive(onNext: showAddSafeZoneVC)
            .addDisposableTo(disposeBag)
       
       tableview.delegate = self
       tableview.dataSource = self
//------------------------------------------------------------------------------------------------------------
    
        tableview.register(R.nib.safezoneCell(), forCellReuseIdentifier: R.reuseIdentifier.safezonecell.identifier)
    }
    
    func reloadData(){
        //拉取数据
        LocationManager.share.fetchSafeZone()
            .bindNext {
                self.fences = $0
                self.tableview.reloadData()
//                self.dataISexit = !self.fences.isEmpty
//                self.tableview.isHidden = !self.dataISexit
            }
            .addDisposableTo(disposeBag)
    }
    
    func showAddSafeZoneVC() {
//        if autopositioningBool ?? false {
        if self.fences.count >= 5 {
            let alertController = UIAlertController(title: nil, message: "not more than 5 safezone", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }else{
            if let vc = R.storyboard.major.addSafeZoneVC() {
                vc.fences = self.fences
                self.navigationController?.show(vc, sender: nil)
            }
        }
//        }else
//        {
//            let alertController = UIAlertController(title: "Warning", message: "Auto-positioning is closed,the location infromation is not timely,for more accurate location infotmation,please inform master to open Autopositioning", preferredStyle: .alert)
//            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//            let stillOpen = UIAlertAction(title: "Still open", style: .cancel, handler: { (UIAlertAction) in
//                print("打开")
//            })
//            alertController.addAction(cancelAction)
//            alertController.addAction(stillOpen)
//            self.present(alertController, animated: true, completion: nil)
//            
//        }
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
        return self.fences.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: R.reuseIdentifier.safezonecell.identifier, for: indexPath) as! SafezoneCell
        
//        cell.nameLabel.text = self.fences[indexPath.row].name
//        cell.addrLabel.text = self.fences[indexPath.row].location?.address
//        cell.switchOnOffQutiet.isOn = self.fences[indexPath.row].active!
        cell.model = self.fences[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 43
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc : AddSafeZoneVC = R.storyboard.major.addSafeZoneVC()  {
            vc.editFenceDataSounrce = self.fences[indexPath.row]
            vc.fences = self.fences
            self.navigationController?.show(vc, sender: nil)
        }
    }
    
    //删除数据源数据
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            //删除
            LocationManager.share.delectSafeZone(self.fences[indexPath.row].ids ?? "").bindNext {
                print($0)
                self.fences.remove(at: indexPath.row)
//                self.tableview.deleteRows(at: [indexPath], with: .top)
                self.tableview.reloadData()
                }.addDisposableTo(disposeBag)
            
        }
        
    }
}

extension SafeZoneController: DZNEmptyDataSetSource {
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {
        return R.image.safe_zone_empty()
    }
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString.init(string: "No Safe zone here,tap \"+\" to add a safe zone")
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return R.color.appColor.background()
    }
}

