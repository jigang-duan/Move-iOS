//
//  AccountController.swift
//  Move App
//
//  Created by Jiang Duan on 17/1/20.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

import RxSwift
import RxDataSources


class AccountController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfCellData>()
        dataSource.configureCell = { ds, tv, ip, item in
            if let userData = item as? UserCellData {
                let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userCell.identifier, for: ip)
                cell.textLabel?.text = userData.account
                return cell
            }
            
            if let devData = item as? DeviceCellData {
                let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.deviceCell.identifier, for: ip)
                cell.textLabel?.text = devData.devType
                return cell
            }
            
            if let sysData = item as? SystemCellData {
                let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.systemCellI.identifier, for: ip)
                cell.textLabel?.text = sysData.title
                return cell
            }
            
            let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.systemCellI.identifier, for: ip)
            return cell
        }
        dataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].header
        }
        
        let sections = [
            SectionOfCellData(header: "", items: [UserCellData(iconUrl: nil, account: "Paul.Wang", describe: "Profile")]),
            SectionOfCellData(header: "Device", items: [DeviceCellData(devType: "Add device", name: nil, iconUrl: nil) ]),
            SectionOfCellData(header: "System", items: [SystemCellData(title: "Language for app") ])
        ]
        
        Observable.just(sections)
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
