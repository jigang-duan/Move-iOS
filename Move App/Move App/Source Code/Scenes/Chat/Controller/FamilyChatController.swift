//
//  FamilyChatController.swift
//  Move App
//
//  Created by yinxiao on 2017/3/24.
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


class FamilyChatController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let bag = DisposeBag()
    
    var messageFramesVariable: Variable<[UUMessageFrame]> = Variable([])
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
                let entitys: [MessageEntity] = list.filter({ ($0.groupId != nil) && ($0.groupId != "") })
                return entitys.map({ it -> UUMessageFrame in
                    var content = UUMessage.Content()
                    content.text = it.content
                    let group = it.owners.first
                    let from = group?.members.filter({ $0.id == it.from }).first
                    let headURL = from?.headPortrait?.fsImageUrl ?? ""
                    
                    let message = UUMessage(icon: headURL,
                                            msgId: "",
                                            time: Date(),
                                            name: "",
                                            content: content,
                                            state: .unread,
                                            type: .text,
                                            from: .other,
                                            showDateLabel: true)
                    return UUMessageFrame(message: message)
                })
            })
        
        tableView.rx.setDelegate(self).addDisposableTo(bag)
        
        messages.bindTo(messageFramesVariable).addDisposableTo(bag)
        
        messageFramesVariable.asObservable()
            .bindTo(tableView.rx.items(cellIdentifier: R.reuseIdentifier.cellFamilyChat.identifier)) { index, model, cell in
                (cell as? UUMessageCell)?.messageFrame = model
            }
            .addDisposableTo(bag)
        
        messageFramesVariable.asObservable()
            .bindNext({_ in
                self.tableViewScrollToBottom()
            })
            .addDisposableTo(bag)
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension FamilyChatController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return messageFramesVariable.value[indexPath.row].cellHeight
    }
}
