//
//  AccountAndChoseDeviceController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/21.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class AccountAndChoseDeviceController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var headOutlet: UIImageView!
    @IBOutlet weak var accountNameOutlet: UILabel!
    @IBOutlet weak var addDeviceOutlet: UIButton!
    @IBOutlet weak var personalInformationOutlet: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    let enterCount = Variable(0)
    let dataSource = RxTableViewSectionedReloadDataSource<SectionOfCellData>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addDeviceOutlet.rx.tap
            .bindNext { _ in
                Distribution.shared.showChoseDeviceScreen()
            }
            .addDisposableTo(disposeBag)
        
        personalInformationOutlet.rx.tap
            .bindNext { _ in
                Distribution.shared.showUserInformationScreen()
            }
            .addDisposableTo(disposeBag)
        
        let viewModel = AccountAndChoseDeviceViewModel(
            input: (enterCount.asObservable()),
            dependency:(
                userManager: UserManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        viewModel.head
            .drive(onNext: { [weak self] in
                self?.headOutlet.imageFromURL($0, placeholder: R.image.member_btn_contact_nor()!)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.accountName
            .drive(accountNameOutlet.rx.text)
            .addDisposableTo(disposeBag)
        
        let dataSource = self.dataSource
        dataSource.configureCell = skinTableViewDataSource
        dataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].header
        }
        tableView.rx
            .setDelegate(self)
            .addDisposableTo(disposeBag)
        viewModel.sections
            .drive(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enterCount.value += 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func skinTableViewDataSource(_ ds: TableViewSectionedDataSource<SectionOfCellData>,
                                 _ tv: UITableView,
                                 _ ip: IndexPath,
                                 _ item: SectionOfCellData.Item) -> UITableViewCell {
        
        let devData = item as! DeviceCellData
        let cell = tv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.choseDevice.identifier, for: ip)
        cell.textLabel?.text = devData.devType
        cell.detailTextLabel?.text = devData.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return ViewUtils.viewForHeaderInSection(text: dataSource[section].header)
    }
    
    // to prevent swipe to delete behavior
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
}
