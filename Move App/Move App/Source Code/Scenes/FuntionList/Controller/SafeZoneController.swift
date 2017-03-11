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

class SafeZoneController: UITableViewController {

    @IBOutlet weak var addSafezone: UIBarButtonItem!
    var disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsetsMake(-40, 0, 0, 0)
        
        addSafezone.rx.tap
            .asDriver()
            .drive(onNext: showAddSafeZoneVC)
            .addDisposableTo(disposeBag)
        
    }
    
    func showAddSafeZoneVC() {
        if let vc = R.storyboard.major.addSafeZoneVC() {
            self.navigationController?.show(vc, sender: nil)
        }
    }
    

    

}
