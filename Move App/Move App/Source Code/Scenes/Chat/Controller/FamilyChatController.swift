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
    @IBOutlet weak var ifView: UUInputView!
    
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
                }
            }
            .addDisposableTo(bag)
        
        messageFramesVariable.asObservable()
            .bindNext({_ in
                self.tableViewScrollToBottom()
            })
            .addDisposableTo(bag)
        
        tableView.rx.itemDeleted.asDriver()
            .drive(onNext: {
                print($0)
            })
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
            .drive(onNext: {
                self.messageFramesVariable.value.append(UUMessageFrame(message: $0))
            })
            .addDisposableTo(bag)
        
        ifView.rx.sendVoice.asObservable()
            .flatMapFirst({ (url, duration) in
                FSManager.shared.uploadVoice(with: try Data(contentsOf: url), duration: duration)
                    .errorOnEmpty()
                    .map({ ($0,duration,url) })
            })
            .map { ImVoice(msg_id: nil, from: uid, to: devuid, gid: group.id, ctime: Date(), fid: $0, readStatus: 0, duration: $1, locationURL: $2) }
            .flatMapLatest({
                IMManager.shared.sendChatVoice($0).catchErrorJustReturn(ImVoice())
            })
            .filter { $0.msg_id != nil }
            .map { UUMessage(imVoice: $0, user: Me.shared.user) }
            .bindNext({
                self.messageFramesVariable.value.append(UUMessageFrame(message: $0))
            })
            .addDisposableTo(bag)

    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension FamilyChatController: UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        return .delete
//    }
    
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


func transformMinuteOffSet(messages: [UUMessage]) -> [UUMessageFrame] {
    return minuteOffSet(messages: messages).map { UUMessageFrame(message: $0) }
}

private func minuteOffSet(messages: [UUMessage]) -> [UUMessage] {
    return messages.reduce([]) { (initianl, next) -> [UUMessage] in
        var message = next
        var result = initianl
        message.minuteOffSet(start: initianl.last?.time ?? Date(timeIntervalSince1970: 0), end: message.time)
        result.append(message)
        return result
    }
}

extension UUMessage {
    
    init(imVoice: ImVoice, user: UserInfo) {
        var content = UUMessage.Content()
        let voice = UUMessage.Voice()
        content.voice = voice
        if let fileUrl = imVoice.locationURL {
            content.voice?.data = try? Data(contentsOf: fileUrl)
            content.voice?.second = imVoice.duration
        }
        self.init(icon: user.profile?.iconUrl?.fsImageUrl ?? "",
                  msgId: imVoice.msg_id ?? "",
                  time: imVoice.ctime ?? Date(),
                  name: user.profile?.nickname ?? "",
                  content: content,
                  state: .unread,
                  type: .voice,
                  from: .me,
                  showDateLabel: true)
    }
    
    init(imEmoji: ImEmoji, user: UserInfo) {
        var content = UUMessage.Content()
        content.emoji = imEmoji.content
        self.init(icon: user.profile?.iconUrl?.fsImageUrl ?? "",
                  msgId: imEmoji.msg_id ?? "",
                  time: imEmoji.ctime ?? Date(),
                  name: user.profile?.nickname ?? "",
                  content: content,
                  state: .unread,
                  type: .emoji,
                  from: .me,
                  showDateLabel: true)
    }
    
    init(userId: String, messageEntity: MessageEntity) {
        var content = UUMessage.Content()
        
        let group = messageEntity.owners.first
        let from = group?.members.filter({ $0.id == messageEntity.from }).first
        let headURL = from?.headPortrait?.fsImageUrl ?? ""
        
        var type = MessageType.text
        let contentType = MessageEntity.ContentType(rawValue: messageEntity.contentType) ?? .unknown
        switch contentType {
        case .text:
            content.emoji = EmojiType(rawValue: messageEntity.content ?? EmojiType.warning.rawValue)
            type = .emoji
        case .voice:
            var voice = UUMessage.Voice()
            voice.url = URL(string: messageEntity.content?.fsImageUrl ?? "")
            content.voice = voice
            content.voice?.second = Int(messageEntity.duration)
            type = .voice
        default: ()
        }
        
        self.init(icon: headURL,
                  msgId: messageEntity.id ?? "",
                  time: messageEntity.createDate ?? Date(),
                  name: from?.nickname ?? "",
                  content: content,
                  state: MessageState(status: messageEntity.readStatus)!,
                  type: type,
                  from: (messageEntity.from == userId) ? .me : .other,
                  showDateLabel: true)
    }
    
}


fileprivate extension MessageState {
    
    init?(status: Int) {
        self.init(status: MessageEntity.ReadStatus(rawValue: status)!)
    }
    
    init?(status: MessageEntity.ReadStatus) {
        self = (status == .unread) ? .unread : .read
    }
    
}
