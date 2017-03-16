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
    
    //internationalization
    @IBOutlet weak var safezoneTitleItem: UINavigationItem!
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var schoolLabel: UILabel!
    
    
    @IBOutlet weak var safezoneQutlet: UIButton!

    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsetsMake(-40, 0, 0, 0)
        
        safezoneQutlet.rx.tap
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
