//
//  WatchFriendsListController.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/7.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources


class WatchFriendsListController: UITableViewController {
    
    
    var viewModel: WatchFriendsListViewModel!
    var disposeBag = DisposeBag()
    let enterCount = Variable(0)
    
    var selectInfo: DeviceFriend?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        enterCount.value += 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = nil
        tableView.dataSource = nil

        tableView.rx
            .setDelegate(self)
            .addDisposableTo(disposeBag)
        
        let selectedFriend = tableView.rx.itemSelected.asDriver()
            .map({ self.viewModel.friends?[$0.row]})
            .filterNil()
        
        viewModel = WatchFriendsListViewModel(
            input: (
                enterCount: enterCount.asDriver(),
                selectedFriend: selectedFriend
            ),
            dependency:(
                deviceManager: DeviceManager.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        
        viewModel.cellDatas?
            .drive(tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)){ (row, element, cell) in
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                cell.textLabel?.text = element.nickname
                
                let imgUrl = MoveApi.BaseURL + "/v1.0/fs/\(element.profile)"
                cell.imageView?.imageFromURL(imgUrl, placeholder:  R.image.member_btn_contact_nor()!)
            }
            .addDisposableTo(disposeBag)
        
        
        viewModel.selected
            .drive(onNext: { [weak self] info  in
                self?.selectInfo = info
                self?.performSegue(withIdentifier: R.segue.watchFriendsListController.showWatchFriendDetail, sender: nil)
            })
            .addDisposableTo(disposeBag)
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = R.segue.watchFriendsListController.showWatchFriendDetail(segue: segue)?.destination {
            vc.friendInfo = selectInfo
        }
        
    }

    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    
}
