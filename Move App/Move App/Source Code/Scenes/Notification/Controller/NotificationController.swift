//
//  NotificationController.swift
//  Move App
//
//  Created by jiang.duan on 2017/3/16.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Realm
import RealmSwift
import RxRealm
import RxDataSources
import RxRealmDataSources

class NotificationController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationOutlet: UINavigationItem!
    
    let bag = DisposeBag()
    
    var gruop: GruopEntity?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationOutlet.title = gruop?.name
        
        let dataSource = RxTableViewRealmDataSource<NoticeEntity>(cellIdentifier: R.reuseIdentifier.cellNotification.identifier,
                                                                 cellType: UUMessageCell.self,
                                                                 cellConfig: cellConfig)
        if let _grouop = gruop {
            let objects = _grouop.notices
            let notices = Observable.changeset(from: objects)
                .share()
            
            tableView.rx.setDelegate(self).addDisposableTo(bag)
            
            notices
                .bindTo(tableView.rx.realmChanges(dataSource))
                .addDisposableTo(bag)
        }
    }
    
    private func cellConfig(cell: UUMessageCell, ip: IndexPath, notice: NoticeEntity) {
        var content = UUMessage.Content()
        content.text = notice.content
        let message = UUMessage(icon: gruop?.headPortrait ?? "",
                                msgId: notice.id ?? "",
                                time: notice.createDate ?? Date(),
                                name: gruop?.name ?? "",
                                content: content,
                                state: (notice.readStatus == NoticeEntity.ReadStatus.read.rawValue) ? .read : .unread,
                                type: .text,
                                from: .other,
                                showDateLabel: true)
        cell.messageFrame = UUMessageFrame(message: message)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

extension NotificationController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cell = tableView.visibleCells[indexPath.row] as? UUMessageCell else {
            return 0.0
        }
        return cell.messageFrame.cellHeight
    }
}
