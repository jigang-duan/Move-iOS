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
    
    let enterController = Variable(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataSource = self.dataSource
        
        dataSource.configureCell = skinTableViewDataSource
        
        dataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].header
        }
        
        let viewModel = AccountViewModel(
            input: (enterController.asObservable()),
            dependency: (
                userManager: UserManager.share,
                deviceInfo: MokDevices()
            )
        )
        
        tableView.rx
            .setDelegate(self)
            .addDisposableTo(disposeBag)
        
        viewModel.sections
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enterController.value += 1
    }
    
    func skinTableViewDataSource(_ ds: TableViewSectionedDataSource<SectionOfCellData>,
                                 _ tv: UITableView,
                                 _ ip: IndexPath,
                                 _ item: SectionOfCellData.Item) -> UITableViewCell {
        
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return ViewUtils.viewForHeaderInSection(text: dataSource[section].header)
    }
    
    // to prevent swipe to delete behavior
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
