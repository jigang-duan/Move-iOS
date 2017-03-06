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
    
    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    let enterCount = Variable(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let viewModel = AccountAndChoseDeviceViewModel(
            input: (enterCount.asObservable()),
            dependency:(
                userManager: UserManager.shared,
                deviceManager: DeviceManager.shared,
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
        
      
        tableView.rx
            .setDelegate(self)
            .addDisposableTo(disposeBag)
        
        viewModel.cellDatas
            .bindTo(tableView.rx.items(cellIdentifier: R.reuseIdentifier.cellDevice.identifier, cellType: UITableViewCell.self)){ (row, element, cell) in
                cell.textLabel?.text = element.devType
                cell.detailTextLabel?.text = element.name
                cell.imageView?.imageFromURL(element.iconUrl!, placeholder:  R.image.member_btn_contact_nor()!)
            }
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

    
    // to prevent swipe to delete behavior
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = AccountKidsRulesuserController()
        self.navigationController?.show(vc, sender: nil)
    }
    
}
