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

class SafeZoneController: UIViewController {
    
    //internationalization
    @IBOutlet weak var safezoneTitleItem: UINavigationItem!

    
    @IBOutlet weak var safezoneQutlet: UIButton!
    @IBOutlet weak var tableview: UITableView!
    var dataISexit: Bool = true
    var disposeBag = DisposeBag()
    
    //var fenceArray: [NSDictionary]?
    var fences: [KidSate.ElectronicFencea] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.contentInset = UIEdgeInsetsMake(-30, 0, 0, 0)
        
        safezoneQutlet.rx.tap
            .asDriver()
            .drive(onNext: showAddSafeZoneVC)
            .addDisposableTo(disposeBag)
       
       tableview.delegate = self
       tableview.dataSource = self
//------------------------------------------------------------------------------------------------------------
        
//        let path = Bundle.main.path(forResource: "safezone.plist", ofType: nil)
//        let dict = NSDictionary(contentsOfFile: path!)
//        fenceArray = dict?["fences"] as? [NSDictionary]
    //拉取数据
        LocationManager.share.fetchSafeZone()
            .bindNext {
                self.fences = $0
                self.tableview.reloadData()
            }
            .addDisposableTo(disposeBag)
       
        
        //缺省
        self.dataISexit = !self.fences.isEmpty
        self.tableview.isHidden = !dataISexit
        
        tableview.register(R.nib.safezoneCell(), forCellReuseIdentifier: R.reuseIdentifier.safezonecell.identifier)
    }
    
    func showAddSafeZoneVC() {
        if let vc = R.storyboard.major.addSafeZoneVC() {
            self.navigationController?.show(vc, sender: nil)
        }
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
        cell.nameLabel.text = self.fences[indexPath.row].name
        cell.addrLabel.text = self.fences[indexPath.row].location?.addr
        cell.switchOnOffQutiet.isOn = self.fences[indexPath.row].active!
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 43
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    //删除数据源数据
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            self.fences.remove(at: indexPath.row)
            //删除
       let _  = LocationManager.share.delectSafeZone(self.fences[indexPath.row].ids!)
            
        }
        tableview.deleteRows(at: [indexPath], with: .top)
        
        tableview.reloadData()
    }
}



