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


class AccountController: UIViewController, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionOfCellData>()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataSource = self.dataSource
        
        dataSource.configureCell = { ds, tv, ip, item in
            if let userData = item as? UserCellData {
                let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userCell.identifier, for: ip)
                cell.textLabel?.text = userData.account
                cell.detailTextLabel?.text = userData.describe
                return cell
            }
            
            if let devData = item as? DeviceCellData {
                let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.deviceCell.identifier, for: ip)
                cell.textLabel?.text = devData.devType
                cell.detailTextLabel?.text = devData.name
                return cell
            }
            
            
            let sysData = item as? AddDeviceCellData
            let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.addDeviceCellI.identifier, for: ip)
            cell.textLabel?.text = sysData?.title
            return cell
        }
        dataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].header
        }
        
        let sections = [
            SectionOfCellData(header: R.string.localizable.id_nil(),
                              items: [UserCellData(iconUrl: nil, account: "Paul.wang@tcl.com", describe: "Profile, password, achievement")]),
            SectionOfCellData(header: R.string.localizable.id_section_header_device(),
                              items: [DeviceCellData(devType: "Family watch 2", name: "Angela", iconUrl: nil),
                                      AddDeviceCellData() ])
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
