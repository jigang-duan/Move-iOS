//
//  ChatViewModel.swift
//  Move App
//
//  Created by yinxiao on 2017/3/21.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import Realm
import RealmSwift
import RxRealm

class ChatViewModel {
    var disposeBag = DisposeBag()
    var dataSource: [UUMessageFrame] = []
    var previousTime: Date? {
        return dataSource.last?.message.time
    }

    func addMyTextItem(_ text: String) {
        let URLStr = "http://img0.bdstatic.com/img/image/shouye/xinshouye/mingxing16.jpg"
        var message = UUMessage.myTextMessage(text, icon: URLStr, name: "Hello,Sister")
        message.minuteOffSet(start: message.time, end: previousTime ?? Date(timeIntervalSince1970: 0))
//        dataSource.append(UUMessageFrame(message: message))
    }

    func addMyPictureItem(_ picture: UIImage) {
        let URLStr = "http://img0.bdstatic.com/img/image/shouye/xinshouye/mingxing16.jpg"
        var message = UUMessage.myPictureMessage(picture , icon: URLStr, name: "Hello,Sister")
        message.minuteOffSet(start: message.time, end: previousTime ?? Date(timeIntervalSince1970: 0))
//        dataSource.append(UUMessageFrame(message: message))
    }

    func addMyVoiceItem(_ voice: Data, second: Int) {
        let URLStr = "http://img0.bdstatic.com/img/image/shouye/xinshouye/mingxing16.jpg"
        var message = UUMessage.myVoiceMessage(voice, second: second, icon: URLStr, name: "Hello,Sister")
        message.minuteOffSet(start: message.time, end: previousTime ?? Date(timeIntervalSince1970: 0))
//        dataSource.append(UUMessageFrame(message: message))
    }


    func addVoiceItemByURL(_ voice: URL, second: Int) {
        let URLStr = "http://img0.bdstatic.com/img/image/shouye/xinshouye/mingxing16.jpg"
        var message = UUMessage.VoiceMessageForURL(voice, second: second, icon: URLStr, name: "Hello,Sister")
        message.minuteOffSet(start: message.time, end: previousTime ?? Date(timeIntervalSince1970: 0))
        dataSource.append(UUMessageFrame(message: message))
    }
}
