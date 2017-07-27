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
import DZNEmptyDataSet


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
        
        self.title = R.string.localizable.id_watch_friends()
        
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.emptyDataSetSource = self

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
        
        tableView.register(R.nib.watchFriendsCell)
        
        viewModel.cellDatas?
            .drive(tableView.rx.items(cellIdentifier: R.reuseIdentifier.watchFriendCell.identifier, cellType: WatchFriendsCell.self)){ (row, element, cell) in
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                cell.kidNameLab.text = element.nickname
                
                let imgUrl = URL(string: FSManager.imageUrl(with: element.profile ?? ""))
                cell.headImgV?.kf.setImage(with: imgUrl, placeholder: R.image.member_btn_contact_nor()!)
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

    
}


extension WatchFriendsListController: DZNEmptyDataSetSource {
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return R.image.watch_friends_empty()!
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = R.string.localizable.id_watch_friends_empty()
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 18.0),
                          NSForegroundColorAttributeName: UIColor.lightGray]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
}


