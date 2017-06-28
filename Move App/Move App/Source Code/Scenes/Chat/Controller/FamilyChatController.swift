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
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    let bag = DisposeBag()
    var messageFramesVariable: Variable<[UUMessageFrame]> = Variable([])
    
    let markReadSubject = PublishSubject<String>()
    let deleteMessageSubject = PublishSubject<Int>()
    
    let enterSubject = PublishSubject<Bool>()
    
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
            //.share()
        
        let chatMessages = messages
            .map { list -> [UUMessage]  in
                list.filter { $0.isGroup }
                    .map { it -> UUMessage in UUMessage(userId: Me.shared.user.id ?? "", messageEntity: it) }
            }
            .map(transformMinuteOffSet)
        
        tableView.rx.setDelegate(self).addDisposableTo(bag)
        
        chatMessages.bindTo(messageFramesVariable).addDisposableTo(bag)
        
        let cellIdentifier = R.reuseIdentifier.cellFamilyChat.identifier
        let messageFramesObservable = messageFramesVariable.asObservable()
        messageFramesObservable
            .bindTo(tableView.rx.items(cellIdentifier: cellIdentifier, cellType: UUMessageCell.self)) { [weak self] (index, model, cell) in
                cell.messageFrame = model
                cell.delegate = self
                cell.menuDelegate = self
                cell.index = index
            }
            .addDisposableTo(bag)
        
        messageFramesObservable
            .filterEmpty()
            .single()
            .bindNext({ [weak self] _ in self?.tableViewScrollToBottom() })
            .addDisposableTo(bag)
        
        let messagesCount = messageFramesObservable.map{ $0.count }.share()
        messagesCount.scan((false, 0)) { ($0.0.1 < $0.1, $0.1) }
            .map{ $0.0 }
            .filter{$0}
            .bindNext({ [weak self] _ in self?.tableViewScrollToBottom() })
            .addDisposableTo(bag)
        
        enterSubject.asObservable()
            .flatMapLatest { (_) in messageFramesObservable }
            .filterEmpty()
            .single()
            .bindNext { [weak self] (_) in
                self?.showFeatureGudieView()
            }
            .addDisposableTo(bag)
        
        
        // MARK: 发送 Enoji 和 语音
        
        let topEnoji = ifView.rx.sendEmoji.asObservable()
            .map { EmojiType(rawValue: $0) }
            .filterNil()
            .map { ImEmoji(msg_id: nil, from: uid, to: devuid, gid: group.id, ctime: Date(), content: $0, failure: false) }
        
        let timingMessages = Observable<Int>.timer(2.0, period: 16.0, scheduler: MainScheduler.instance)
            .map { _ in group.messages  }
            .share()
        
        let resendEnoji = timingMessages
            .map { $0.filter{ $0.isTextOfFailed }.first }
            .filterNil()
            .map { ImEmoji(entity: $0) }
        
        let needResendVoice = timingMessages
            .map { $0.filter{ $0.isVoiceOfFailed }.first }
            .filterNil()
            .map { ImVoice(entity: $0) }
            .filter { $0.from == uid }
        
        let resendVoice = needResendVoice
            .filter { ($0.fid != nil) && ($0.locationURL == nil) }
        
        let needReUpdateVoice = needResendVoice
            .filter { ($0.fid != nil) && ($0.locationURL != nil) }
        
        let sendEnoji = Observable.merge(topEnoji, resendEnoji)
            .flatMapLatest { IMManager.shared.sendChatEmoji($0).catchErrorJustReturn($0.clone(failure: true)) }
            .share()
        
        let sentEnoji = sendEnoji
            .filter { $0.msg_id != nil }
            .map { MessageEntity(meoji: $0) }
        
        let failedEnoji = sendEnoji
            .filter { $0.msg_id == nil }
            .map { MessageEntity(meoji: $0) }
        
        let topVoice = ifView.rx.sendVoice.asObservable()
            .map { ImVoice(msg_id: nil, from: uid, to: devuid, gid: group.id, ctime: Date(), fid: nil, readStatus: 0, duration: $1, locationURL: $0) }
        
        
        let activitying = ActivityIndicator()
        let activityIn = activitying.asObservable()
        activityIn.map{!$0}.bindTo(activityView.rx.isHidden).addDisposableTo(bag)
        activityIn.bindTo(activityView.rx.isAnimating).addDisposableTo(bag)
        
        let updateVoice = Observable.merge(topVoice, needReUpdateVoice)
            .filter { ($0.locationURL != nil) && ($0.duration != nil) }
            .flatMapFirst { (imVoice) in
                FSManager.shared.uploadVoice(with: try Data(contentsOf: imVoice.locationURL!), duration: imVoice.duration!)
                    .trackActivity(activitying, need: imVoice.readStatus == 0)
                    .catchErrorJustReturn(imVoice.locationURL!.absoluteString)
                    .map { imVoice.clone(fId: $0) }
            }
        
        let sendVoice = Observable.merge(updateVoice, resendVoice)
            .flatMapLatest { IMManager.shared.sendChatVoice($0).catchErrorJustReturn($0.clone(failure: true)) }
            .share()
        
        let sentVoice = sendVoice
            .filter { $0.msg_id != nil }
            .map { MessageEntity(voice: $0) }
        
        let failedVoice = sendVoice
            .filter { $0.msg_id == nil }
            .map { MessageEntity(voice: $0) }
        
        Observable.merge(sentEnoji, sentVoice)
            .bindNext { group.update(realm: realm, message: $0, readStatus: .sent) }
            .addDisposableTo(bag)
        
        Observable.merge(failedEnoji, failedVoice)
            .bindNext { group.update(realm: realm, message: $0, readStatus: .failedSend) }
            .addDisposableTo(bag)
        
        tableView.rx.itemSelected
            .bindNext({ print($0) })
            .addDisposableTo(bag)
        
        moreView.delegate = self
        
        // MARK: 删除
        
        //let itemDeleted = tableView.rx.itemDeleted.asObservable().map({ $0.row })
        let itemDeleted = deleteMessageSubject
        itemDeleted
            .withLatestFrom(messageFramesVariable.asObservable()) { $1[$0].message.msgId }
            .flatMapLatest { IMManager.shared.delete(message: $0).catchErrorJustReturn("") }
            .filterEmpty()
            .map { realm.object(ofType: MessageEntity.self, forPrimaryKey: $0) }
            .filterNil()
            .subscribe(realm.rx.delete())
            .addDisposableTo(bag)
        
        let deleteMessages = moreView.rx.delete.asObservable()
            .filterEmpty()
            .withLatestFrom(messageFramesVariable.asObservable()) { (indexs, messages) in indexs.map({ messages[$0].message.msgId }) }
        
        let clearMessages = moreView.rx.clearAll.asObservable()
            .withLatestFrom(messageFramesVariable.asObservable()) { $0.1.map({$0.message.msgId}) }
            
        Observable.merge(deleteMessages, clearMessages)
            .flatMapLatest { IMManager.shared.delete(messages: $0).catchErrorJustReturn($0) }
            .map { ids in ids.flatMap {realm.object(ofType: MessageEntity.self, forPrimaryKey: $0)} }
            .subscribe(realm.rx.delete())
            .addDisposableTo(bag)
        
        // mark Read
        markReadSubject.asObserver()
            .flatMapLatest { IMManager.shared.mark(message: $0).catchErrorJustReturn($0) }
            .filterEmpty()
            .subscribe(onNext: { group.markRead(realm: realm, message: $0) })
            .addDisposableTo(bag)
        
        Observable<Int>.timer(1.0, period: 6.0, scheduler: MainScheduler.instance)
            .map { _ in group.messages  }
            .map { list -> [MessageEntity] in list.filter { $0.isGroup && $0.isText && $0.isUnRead } }
            .filterEmpty()
            .subscribe(onNext: { markRead(realm: realm, messages: $0) })
            .addDisposableTo(bag)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesturedDid(_:)))
        ifView.rx.unfold.asObservable()
            .bindNext { [weak self] (unfold) in
                unfold ? self?.tableView.addGestureRecognizer(tapGesture) : self?.tableView.removeGestureRecognizer(tapGesture)
            }
            .addDisposableTo(bag)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enterSubject.onNext(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.UUAVAudioPlayerForcedStopPlay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


extension FamilyChatController {
    
    fileprivate func UUAVAudioPlayerForcedStopPlay() {
        // 关闭红外线感应
        UIDevice.current.isProximityMonitoringEnabled = false
        UUAVAudioPlayer.shared.stop()
    }

    fileprivate func showFeatureGudieView() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            if let cell = tableView.visibleCells.first as? UUMessageCell {
                let featureItem = EAFeatureItem(focus: cell.btnContent,
                                                focusCornerRadius: 6 ,
                                                focus: UIEdgeInsets.zero)
                featureItem?.actionTitle = R.string.localizable.id_first_entry_tips()
                featureItem?.introduce = R.string.localizable.id_long_press_to_delete()
                self.view.show(with: [featureItem!], saveKeyName: "mark:familychat:cell:content", inVersion: version)
            }
        }
    }
}

extension FamilyChatController: UUMessageCellDelegate {
    
    func cellContentDidClick(cell: UUMessageCell, voice messageId: String) {
        if cell.messageFrame.message.from == .other {
            markReadSubject.onNext(messageId)
        }
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
        if title == UUMessageCell.MenuItem_Delete {
            delete(index: index)
        } else if title == UUMessageCell.MenuItem_More {
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.groupTableViewBackground
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
    
    func tapGesturedDid(_ sender: UITapGestureRecognizer) {
        ifView.shrinkEmoji()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        ifView.shrinkEmoji()
    }
}

extension FamilyChatController: DZNEmptyDataSetSource {
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return R.image.message_friends_empty()!
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = R.string.localizable.id_no_message_here()
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 18.0),
                          NSForegroundColorAttributeName: UIColor.lightGray]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return R.color.appColor.background()
    }
}

extension ObservableConvertibleType {
    func trackActivity(_ activityIndicator: ActivityIndicator, need: Bool) -> Observable<E> {
        return need ? trackActivity(activityIndicator) : asObservable()
    }
}
