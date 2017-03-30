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
            .map({ list -> [UUMessageFrame]  in
                let entitys: [MessageEntity] = list.filter({ ($0.groupId != nil) && ($0.groupId != "") })
                return entitys.map({ it -> UUMessageFrame in
                    UUMessageFrame(userId: Me.shared.user.id ?? "", messageEntity: it)
                })
            })
        
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
        
        ifView.rx.sendEmoji.asDriver()
            .map({ EmojiType(rawValue: $0) })
            .filterNil()
            .flatMapLatest({
                IMManager.shared.sendChatEmoji(ImEmoji(msg_id: nil, from: uid, to: devuid, gid: group.id, ctime: Date(), content: $0))
                    .asDriver(onErrorJustReturn: ImEmoji())
            })
            .filter({ $0.msg_id != nil })
            .drive(onNext: {
                self.messageFramesVariable.value.append(UUMessageFrame(imEmoji: $0, user: Me.shared.user))
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
            .filter({ $0.msg_id != nil })
            .bindNext({
                self.messageFramesVariable.value.append(UUMessageFrame(imVoice: $0, user: Me.shared.user))
            })
            .addDisposableTo(bag)

    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension FamilyChatController: UITableViewDelegate {
    
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


extension UUMessageFrame {
    
    init(imVoice: ImVoice, user: UserInfo) {
        var content = UUMessage.Content()
        let voice = UUMessage.Voice()
        content.voice = voice
        if let fileUrl = imVoice.locationURL {
            content.voice?.data = try? Data(contentsOf: fileUrl)
        }
        let message = UUMessage(icon: user.profile?.iconUrl?.fsImageUrl ?? "",
                                msgId: imVoice.msg_id ?? "",
                                time: imVoice.ctime ?? Date(),
                                name: user.profile?.nickname ?? "",
                                content: content,
                                state: .unread,
                                type: .voice,
                                from: .me,
                                showDateLabel: true)
        self.init(message: message)
    }
    
    init(imEmoji: ImEmoji, user: UserInfo) {
        var content = UUMessage.Content()
        content.emoji = imEmoji.content
        let message = UUMessage(icon: user.profile?.iconUrl?.fsImageUrl ?? "",
                                msgId: imEmoji.msg_id ?? "",
                                time: imEmoji.ctime ?? Date(),
                                name: user.profile?.nickname ?? "",
                                content: content,
                                state: .unread,
                                type: .emoji,
                                from: .me,
                                showDateLabel: true)
        self.init(message: message)
    }

    init(userId: String, messageEntity: MessageEntity) {
        var content = UUMessage.Content()
        
        let group = messageEntity.owners.first
        let from = group?.members.filter({ $0.id == messageEntity.from }).first
        let headURL = from?.headPortrait?.fsImageUrl ?? ""
        
        var type = MessageType.text
        if messageEntity.contentType == 1 {
            content.emoji = EmojiType(rawValue: messageEntity.content ?? EmojiType.warning.rawValue)
            type = .emoji
        } else if messageEntity.contentType == 3 {
            var voice = UUMessage.Voice()
            voice.url = URL(string: messageEntity.content?.fsImageUrl ?? "")
            content.voice = voice
            type = .voice
        }
        
        let message = UUMessage(icon: headURL,
                                msgId: messageEntity.id ?? "",
                                time: messageEntity.createDate ?? Date(),
                                name: from?.nickname ?? "",
                                content: content,
                                state: (messageEntity.readStatus == 0) ? .unread : .read,
                                type: type,
                                from: (messageEntity.from == userId) ? .me : .other,
                                showDateLabel: true)
        self.init(message: message)
    }

}
