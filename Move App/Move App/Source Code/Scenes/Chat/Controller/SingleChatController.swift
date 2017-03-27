//
//  SingleChatController.swift
//  Move App
//
//  Created by jiang.duan on 2017/3/26.
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

class SingleChatController: UIViewController {

    @IBOutlet var ifView: UUInputView!
    @IBOutlet weak var tableView: UITableView!
    
    let bag = DisposeBag()
    var messageFramesVariable: Variable<[UUMessageFrame]> = Variable([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(ifView)

        // Do any additional setup after loading the view.
        guard
            let uid = Me.shared.user.id,
            let devuid = DeviceManager.shared.currentDevice?.user?.uid else {
                return
        }
        
        let realm = try! Realm()
        guard let groups = realm.objects(SynckeyEntity.self).filter("uid == %@", uid).first?.groups,
            let group = groups.filter({ $0.members.contains(where: { $0.id == devuid }) }).first else {
                return
        }
        
        let messages = Observable.collection(from: group.messages)
            .share()
            .map({ list -> [UUMessageFrame]  in
                let entitys: [MessageEntity] = list.filter({ ($0.groupId == nil) || ($0.groupId == "") })
                return entitys.map({ it -> UUMessageFrame in
                    UUMessageFrame(userId: Me.shared.user.id ?? "", messageEntity: it)
                })
            })
        
        tableView.rx.setDelegate(self).addDisposableTo(bag)
        
        messages.bindTo(messageFramesVariable).addDisposableTo(bag)
        
        messageFramesVariable.asObservable()
            .bindTo(tableView.rx.items(cellIdentifier: R.reuseIdentifier.cellSingleChat.identifier)) { index, model, cell in
                if let cell = cell as? UUMessageCell {
                    cell.messageFrame = model
                }
            }
            .addDisposableTo(bag)
        
        messageFramesVariable.asObservable()
            .bindNext({_ in
                self.tableViewScrollToBottom()
            })
            .addDisposableTo(bag)
        
        
        ifView.rx.sendEmoji.asDriver()
            .map({ EmojiType(rawValue: $0) })
            .filterNil()
            .flatMapLatest({
                IMManager.shared.sendChatEmoji(ImEmoji(msg_id: nil, from: uid, to: devuid, gid: "", content: $0, ctime: Date()))
                    .asDriver(onErrorJustReturn: ImEmoji())
            })
            .filter({ $0.msg_id != nil  })
            .drive(onNext: {
                self.messageFramesVariable.value.append(UUMessageFrame(imEmoji: $0, user: Me.shared.user))
            })
            .addDisposableTo(bag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension SingleChatController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return messageFramesVariable.value[indexPath.row].cellHeight
    }
    
    fileprivate func tableViewScrollToBottom() {
        guard messageFramesVariable.value.count > 0 else {
            return
        }
        let indexPath = IndexPath(row: messageFramesVariable.value.count - 1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}
