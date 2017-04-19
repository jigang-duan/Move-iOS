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
import DZNEmptyDataSet


class FamilyChatController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ifView: UUInputView!
    @IBOutlet var moreView: MoreView!
    
    let bag = DisposeBag()
    var messageFramesVariable: Variable<[UUMessageFrame]> = Variable([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(ifView)
        self.view.addSubview(moreView)
        
        // Do any additional setup after loading the view.
        tableView.emptyDataSetSource = self
        moreView.isHidden = true
        
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
            .map({ list -> [UUMessage]  in
                let entitys: [MessageEntity] = list.filter({ ($0.groupId != nil) && ($0.groupId != "") })
                return entitys.map { it -> UUMessage in UUMessage(userId: Me.shared.user.id ?? "", messageEntity: it) }
            })
            .map(transformMinuteOffSet)
        
        tableView.rx.setDelegate(self).addDisposableTo(bag)
        
        
        messages.bindTo(messageFramesVariable).addDisposableTo(bag)
        
        messageFramesVariable.asObservable()
            .bindTo(tableView.rx.items(cellIdentifier: R.reuseIdentifier.cellFamilyChat.identifier)) { index, model, cell in
                if let cell = cell as? UUMessageCell {
                    cell.messageFrame = model
                    cell.menuDelegate = self
                    cell.index = index
                }
            }
            .addDisposableTo(bag)
        
        messageFramesVariable.asObservable()
            .bindNext({ [weak self] _ in
                self?.tableViewScrollToBottom()
            })
            .addDisposableTo(bag)
        

        let itemDeleted = tableView.rx.itemDeleted.asObservable()
        itemDeleted.map({ $0.row })
            .withLatestFrom(messageFramesVariable.asObservable()) { $1[$0].message.msgId }
            .flatMapLatest({ IMManager.shared.delete(message: $0).catchErrorJustReturn("") })
            .filterEmpty()
            .map({
                realm.object(ofType: MessageEntity.self, forPrimaryKey: $0)
            })
            .filterNil()
            .subscribe(realm.rx.delete())
            .addDisposableTo(bag)
        
        
        ifView.rx.sendEmoji.asDriver()
            .map({ EmojiType(rawValue: $0) })
            .filterNil()
            .flatMapLatest({
                IMManager.shared.sendChatEmoji(ImEmoji(msg_id: nil, from: uid, to: devuid, gid: group.id, ctime: Date(), content: $0))
                    .asDriver(onErrorJustReturn: ImEmoji())
            })
            .filter({ $0.msg_id != nil })
            .map { UUMessage(imEmoji: $0, user: Me.shared.user) }
            .drive(onNext: { [weak self] in
                self?.messageFramesVariable.value.append(UUMessageFrame(message: $0))
            })
            .addDisposableTo(bag)
        
        ifView.rx.sendVoice.asObservable()
            .flatMapFirst({ (url, duration) in
                FSManager.shared.uploadVoice(with: try Data(contentsOf: url), duration: duration)
                    .catchErrorJustReturn("")
                    .map({ ($0,duration,url) })
            })
            .map { ImVoice(msg_id: nil, from: uid, to: devuid, gid: group.id, ctime: Date(), fid: $0, readStatus: 0, duration: $1, locationURL: $2) }
            .flatMapLatest({
                IMManager.shared.sendChatVoice($0).catchErrorJustReturn(ImVoice())
            })
            .filter { $0.msg_id != nil }
            .map { UUMessage(imVoice: $0, user: Me.shared.user) }
            .bindNext({ [weak self] in
                self?.messageFramesVariable.value.append(UUMessageFrame(message: $0))
            })
            .addDisposableTo(bag)
        
        tableView.rx.itemSelected
            .bindNext({
                print($0)
            })
            .addDisposableTo(bag)
        
        moreView.delegate = self
        
        let deleteMessages = moreView.rx.delete.asObservable()
            .withLatestFrom(messageFramesVariable.asObservable()) { (indexs, messages) in  indexs.map({  messages[$0].message.msgId }) }
        
        let clearMessages = moreView.rx.clearAll.asObservable()
            .withLatestFrom(messageFramesVariable.asObservable()) {  $0.1.map({$0.message.msgId}) }
            
        Observable.merge(deleteMessages, clearMessages)
            .flatMapLatest({ IMManager.shared.delete(messages: $0).catchErrorJustReturn($0)  })
            .map({ ids in ids.flatMap {realm.object(ofType: MessageEntity.self, forPrimaryKey: $0)} })
            .subscribe(realm.rx.delete())
            .addDisposableTo(bag)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension FamilyChatController: MoreViewDelegate {
    
    func multipleChoice(moreView: MoreView) -> [Int] {
        return tableView.indexPathsForSelectedRows?.map({ $0.row }) ?? []
    }
   
    func complete(moreView: MoreView) {
        if tableView.isEditing {
            tableView.allowsMultipleSelectionDuringEditing = false
            tableView.isEditing = false
            moreView.isHidden = true
            ifView.isHidden = false
        }
    }
}

extension FamilyChatController: UUMessageCellMenuDelegate {
    
    func handleMenu(cell: UUMessageCell, menuItem title: String, at index: Int) {
        if title == "Delete" {
            delete(index: index)
        } else if title == "More" {
            more()
        }
    }
    
    private func delete(index: Int) {
        tableView.dataSource?.tableView?(tableView, commit: .delete, forRowAt: IndexPath(row: index, section: 0))
    }
    
    private func more() {
        if !tableView.isEditing {
            tableView.allowsMultipleSelectionDuringEditing = true
            tableView.isEditing = true
            moreView.isHidden = false
            ifView.isHidden = true
        }
    }
}

extension FamilyChatController: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
    }
    
    
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

extension FamilyChatController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        ifView.shrinkEmoji()
    }
}

extension FamilyChatController: DZNEmptyDataSetSource {
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {
        return R.image.message_friends_empty()!
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return R.color.appColor.background()
    }
}

