//
//  MessageModel.swift
//  Move App
//
//  Created by jiang.duan on 2017/4/1.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

func transformMinuteOffSet(messages: [UUMessage]) -> [UUMessageFrame] {
    return minuteOffSet(messages: messages).map { UUMessageFrame(message: $0) }
}

func transformSet(messages: [UUMessage]) -> [UUMessageFrame] {
    return messages.map { UUMessageFrame(message: $0) }
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

func markRead(realm: Realm, messages: [MessageEntity]) {
    try? realm.write {
        messages.forEach { (entity) in
            entity.readStatus = MessageEntity.ReadStatus.read.rawValue
        }
    }
}

func markRead(realm: Realm, notices: [NoticeEntity]) {
    try? realm.write {
        notices.forEach { (entity) in
            entity.readStatus = NoticeEntity.ReadStatus.read.rawValue
        }
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
            content.voice?.url = URL(string: imVoice.fid?.fsImageUrl ?? "")
        }
        self.init(icon: user.profile?.iconUrl?.fsImageUrl ?? "",
                  msgId: imVoice.msg_id ?? "",
                  time: imVoice.ctime,
                  name: user.profile?.nickname ?? "",
                  content: content,
                  state: .unread,
                  type: .voice,
                  from: .me,
                  isFailure: imVoice.readStatus == MessageEntity.ReadStatus.readySend.rawValue,
                  showDateLabel: true)
    }
    
    init(imEmoji: ImEmoji, user: UserInfo) {
        var content = UUMessage.Content()
        content.emoji = imEmoji.content
        self.init(icon: user.profile?.iconUrl?.fsImageUrl ?? "",
                  msgId: imEmoji.msg_id ?? "",
                  time: imEmoji.ctime,
                  name: user.profile?.nickname ?? "",
                  content: content,
                  state: .unread,
                  type: .emoji,
                  from: .me,
                  isFailure: imEmoji.failure ?? false,
                  showDateLabel: true)
    }
    
    init(userId: String, messageEntity: MessageEntity) {
        var content = UUMessage.Content()
        
        let group = messageEntity.owners.first
        let from = group?.members.filter({ $0.id == messageEntity.from }).first
        
        var headURL = ""
        if let headPortrait = from?.headPortrait, headPortrait.isNotEmpty {
            headURL = headPortrait.fsImageUrl
        } else if let indentiy = from?.identity, indentiy.isNotEmpty {
            let relation = Relation(input: indentiy)
            headURL = relation?.imageName ?? ""
        }
        
        var name = ""
        if let indentiy = from?.identity, indentiy.isNotEmpty {
            let relation = Relation(input: indentiy)
            name = relation?.description ?? ""
        } else {
            name = from?.nickname ?? ""
        }
        
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
                  name: name,
                  content: content,
                  state: MessageState(status: messageEntity.readStatus)!,
                  type: type,
                  from: (messageEntity.from == userId) ? .me : .other,
                  isFailure: messageEntity.readStatus == MessageEntity.ReadStatus.readySend.rawValue,
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
