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
import DZNEmptyDataSet


class NotificationController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationOutlet: UINavigationItem!
    @IBOutlet var moreView: MoreView!
    
    let bag = DisposeBag()
    
    var group: GroupEntity?
    var messageFramesVariable: Variable<[UUMessageFrame]> = Variable([])
    
    let deleteMessageSubject = PublishSubject<Int>()
    let enterSubject = PublishSubject<Void>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(moreView)
        
        // Do any additional setup after loading the view.
        tableView.emptyDataSetSource = self
        moreView.isHidden = true
        
        guard let uid = Me.shared.user.id else {
            return
        }
        
        let kidsId = group?.notices.first?.from
        let kids = group?.members.filter({ $0.id == kidsId }).first
        navigationOutlet.title = kids?.nickname
        
        if let _group = group {
            let objects = _group.notices
            let notices = Observable.collection(from: objects)
                .share()
                .map { list -> [UUMessage] in
                    list.filter { $0.to == uid }
                        .filter { $0.imType.atNotiicationPage }
                        .sorted(by: { $0.createDate! > $1.createDate! })
                        .map { notice -> UUMessage in
                            var content = UUMessage.Content()
                            content.text = notice.content
                            return UUMessage(icon: FSManager.imageUrl(with: _group.headPortrait ?? ""),
                                                msgId: notice.id ?? "",
                                                time: notice.createDate ?? Date(),
                                                name: _group.name ?? "",
                                                content: content,
                                                state: !notice.isUnRead ? .read : .unread,
                                                type: .text,
                                                from: .other,
                                                isFailure: false,
                                                showDateLabel: true)
                    }
                }
                .map(transformMinuteOffSet)
            
            
            tableView.rx.setDelegate(self).addDisposableTo(bag)
            
            //let itemDeleted = tableView.rx.itemDeleted.asObservable().map({ $0.row })
            let itemDeleted = deleteMessageSubject
            itemDeleted
                .withLatestFrom(messageFramesVariable.asObservable()) { $1[$0].message.msgId }
                .filterEmpty()
                .map({ id in
                    objects.filter({ $0.id == id }).first
                })
                .filterNil()
                .subscribe(Realm.rx.delete())
                .addDisposableTo(bag)
            
            notices.bindTo(messageFramesVariable).addDisposableTo(bag)
            
            let cellIdentifier = R.reuseIdentifier.cellNotification.identifier
            let messageFramesObservable = messageFramesVariable.asObservable()
            messageFramesObservable
                .bindTo(tableView.rx.items(cellIdentifier: cellIdentifier, cellType: UUMessageCell.self)) { [weak self] (index, model, cell) in
                    cell.messageFrame = model
                    cell.menuDelegate = self
                    cell.index = index
                }
                .addDisposableTo(bag)
            
            enterSubject.asObservable()
                .flatMapLatest { messageFramesObservable }
                .filterEmpty()
                .single()
                .bindNext { [weak self] (_) in
                    self?.showFeatureGudieView()
                }
                .addDisposableTo(bag)
            
            moreView.delegate = self
            
            let deleteMessages = moreView.rx.delete.asObservable()
                .withLatestFrom(messageFramesVariable.asObservable()) { (indexs, messages) in  indexs.map({  messages[$0].message.msgId }) }
            
            let clearMessages = moreView.rx.clearAll.asObservable()
                .withLatestFrom(messageFramesVariable.asObservable()) {  $0.1.map({$0.message.msgId}) }
            
            Observable.merge(deleteMessages, clearMessages)
                .map({ ids in ids.flatMap { id in objects.filter({ $0.id == id }).first } })
                .subscribe(Realm.rx.delete())
                .addDisposableTo(bag)
            
            let realm = try! Realm()
            Observable<Int>.timer(1.0, period: 6.0, scheduler: MainScheduler.instance)
                .map { _ in objects  }
                .map { list -> [NoticeEntity] in list.filter { $0.isUnRead } }
                .filterEmpty()
                .subscribe(onNext: { markRead(realm: realm, notices: $0) })
                .addDisposableTo(bag)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enterSubject.onNext(())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension NotificationController {
    
    fileprivate func tableViewScrollToBottom() {
        guard messageFramesVariable.value.count > 0 else {
            return
        }
        let indexPath = IndexPath(row: messageFramesVariable.value.count - 1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    fileprivate func showFeatureGudieView() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            if let cell = tableView.visibleCells.first as? UUMessageCell {
                let featureItem = EAFeatureItem(focus: cell.btnContent,
                                                focusCornerRadius: 6 ,
                                                focus: UIEdgeInsets.zero)
                featureItem?.actionTitle = "I Know"
                featureItem?.introduce = "Long press to delete"
                self.view.show(with: [featureItem!], saveKeyName: "mark:notification:cell:content", inVersion: version)
            }
        }
    }
    
}


extension NotificationController: MoreViewDelegate {
    
    func multipleChoice(moreView: MoreView) -> [Int] {
        return tableView.indexPathsForSelectedRows?.map({ $0.row }) ?? []
    }
    
    func complete(moreView: MoreView) {
        if tableView.isEditing {
            tableView.allowsMultipleSelectionDuringEditing = false
            tableView.isEditing = false
            moreView.isHidden = true
        }
    }
}

extension NotificationController: UUMessageCellMenuDelegate {
    
    func handleMenu(cell: UUMessageCell, menuItem title: String, at index: Int) {
        if title == "Delete" {
            delete(index: index)
        } else if title == "More" {
            more()
        }
    }
    
    private func delete(index: Int) {
        //tableView.dataSource?.tableView?(tableView, commit: .delete, forRowAt: IndexPath(row: index, section: 0))
        deleteMessageSubject.onNext(index)
    }
    
    private func more() {
        if !tableView.isEditing {
            tableView.allowsMultipleSelectionDuringEditing = true
            tableView.isEditing = true
            moreView.isHidden = false
        }
    }
}

extension NotificationController: UITableViewDelegate {
    
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.groupTableViewBackground
    }
}

extension NotificationController: DZNEmptyDataSetSource {
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return R.image.system_notification_empty()!
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "No notification here"
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 18.0),
                          NSForegroundColorAttributeName: UIColor.lightGray]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return R.color.appColor.background()
    }
}
