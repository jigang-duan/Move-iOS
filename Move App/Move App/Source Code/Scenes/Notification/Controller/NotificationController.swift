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
    
    var group: GroupEntity?
    var messageFramesVariable: Variable<[UUMessageFrame]> = Variable([])

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationOutlet.title = group?.name
        
        if let _group = group {
            let objects = _group.notices
            let notices = Observable.collection(from: objects)
                .share()
                .map({ list -> [UUMessageFrame] in
                    list.map({ notice -> UUMessageFrame in
                        var content = UUMessage.Content()
                        content.text = notice.content
                        let message = UUMessage(icon: _group.headPortrait ?? "",
                                                msgId: notice.id ?? "",
                                                time: notice.createDate ?? Date(),
                                                name: _group.name ?? "",
                                                content: content,
                                                state: (notice.readStatus == NoticeEntity.ReadStatus.read.rawValue) ? .read : .unread,
                                                type: .text,
                                                from: .other,
                                                showDateLabel: true)
                        return UUMessageFrame(message: message)
                    })
                })
            
            
            tableView.rx.setDelegate(self).addDisposableTo(bag)
            
            notices.bindTo(messageFramesVariable).addDisposableTo(bag)
            
            messageFramesVariable.asObservable()
                .bindTo(tableView.rx.items(cellIdentifier: R.reuseIdentifier.cellNotification.identifier)) { index, model, cell in
                    if let _cell = cell as? UUMessageCell {
                        _cell.messageFrame = model
                    }
                }
                .addDisposableTo(bag)
            
            messageFramesVariable.asObservable().bindNext({_ in
                self.tableViewScrollToBottom()
            })
                .addDisposableTo(bag)
        }
    }
    
    private func tableViewScrollToBottom() {
        guard tableView.visibleCells.count > 0 else {
            return
        }
        let indexPath = IndexPath(row: tableView.visibleCells.count - 1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

extension NotificationController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return messageFramesVariable.value[indexPath.row].cellHeight
    }
}
