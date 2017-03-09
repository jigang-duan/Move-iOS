//
//  RemindersController.swift
//  Move App
//
//  Created by jiang.duan on 2017/2/27.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CustomViews

class RemindersController: UIViewController {

    @IBOutlet weak var addOutlet: UIButton!
    @IBOutlet weak var tableViw: UITableView!
    
    var disposeBag = DisposeBag()
    
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addFuntion()
        self.tableViw.delegate = self
        self.tableViw.contentInset = UIEdgeInsetsMake(-30, 0, 0, 0)
        
    }

    func addFuntion() {
        // Do any additional setup after loading the view.
        let popover = RxPopover.shared
        popover.style = .dark
        let action1 = BasePopoverAction(placeholderImage: R.image.member_ic_qr(),
                                        title: "Alarm",
                                        isSelected: false)
        let action2 = BasePopoverAction(placeholderImage: R.image.member_ic_input(),
                                        title: "To do list",
                                        isSelected: false)
        addOutlet.rx.tap.asObservable()
            .flatMapLatest {
                popover.promptFor(toView: self.addOutlet, actions: [action1, action2])
            }
            .bindNext(showSubController)
            .addDisposableTo(disposeBag)
    }

}

extension RemindersController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.cellAlarm.identifier, for: indexPath)
        cell.textLabel?.text = "08:00"
        cell.detailTextLabel?.text = "School time"
        let imag = UIImage.init(named: "reminder_school")
        cell.imageView?.image = imag
       
        return cell
    }
    
    

}


extension RemindersController {

    func showSubController(action: BasePopoverAction) {
        if action.title == "Alarm" {
            self.performSegue(withIdentifier: R.segue.remindersController.showAlarm, sender: nil)
        } else if action.title == "To do list" {
            self.performSegue(withIdentifier: R.segue.remindersController.showTodolist, sender: nil)
        }
    }
}
