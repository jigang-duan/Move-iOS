//
//  ChatViewController.swift
//  UUChat
//
//  Created by jiang.duan on 2017/3/1.
//  Copyright © 2017年 jiang.duan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Realm
import RealmSwift
import RxRealm
import RxDataSources
import RxRealmDataSources

class ChatModel {
    var disposeBag = DisposeBag()
    var dataSource: [UUMessageFrame] = []
    var previousTime: Date? {
        return dataSource.last?.message.time
    }
    
    func addMyTextItem(_ text: String) {
        let URLStr = "http://img0.bdstatic.com/img/image/shouye/xinshouye/mingxing16.jpg"
        var message = UUMessage.myTextMessage(text, icon: URLStr, name: "Hello,Sister")
        message.minuteOffSet(start: message.time, end: previousTime ?? Date(timeIntervalSince1970: 0))
        var sendMessage = MoveIM.ImMessage()

//        sendMessage.type = 1
        sendMessage.from = UserInfo.shared.id
        sendMessage.to = "15616530027750325535"
        sendMessage.content = "4,070b0903c92e"
        sendMessage.content_type = 2
        sendMessage.ctime = message.time
        
        IMManager.shared.sendChatMessage(message: sendMessage).subscribe { [weak self] info in
            switch info {
            case .completed:
                print("completed")
            case .error(let error):
                print(error.localizedDescription)
            case .next(let result):
                print(result.local_id ?? "local is null" + "  " + result.msg_id! )
                message.msgId = result.msg_id!
                self?.dataSource.append(UUMessageFrame(message: message))
            }
            }.addDisposableTo(disposeBag)
    }
    
    func addMyPictureItem(_ picture: UIImage) {
        let URLStr = "http://img0.bdstatic.com/img/image/shouye/xinshouye/mingxing16.jpg"
        var message = UUMessage.myPictureMessage(picture , icon: URLStr, name: "Hello,Sister")
        message.minuteOffSet(start: message.time, end: previousTime ?? Date(timeIntervalSince1970: 0))
        dataSource.append(UUMessageFrame(message: message))
    }
    
    func addMyVoiceItem(_ voice: Data, second: Int) {
        let URLStr = "http://img0.bdstatic.com/img/image/shouye/xinshouye/mingxing16.jpg"
        var message = UUMessage.myVoiceMessage(voice, second: second, icon: URLStr, name: "Hello,Sister")
        message.minuteOffSet(start: message.time, end: previousTime ?? Date(timeIntervalSince1970: 0))
        dataSource.append(UUMessageFrame(message: message))
    }
}


class ChatViewController: UIViewController {

    @IBOutlet weak var ifView: UUInputFunctionView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var chatModel: ChatModel!
    var disposeBag = DisposeBag()
    var message: MessageEntity?
    var messageFramesVariable: Variable<[UUMessageFrame]> = Variable([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.chatModel = ChatModel()
        self.view.addSubview(ifView)
        ifView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self

        IMManager.shared.getGroups().subscribe {list in
            switch list {
            case .next(let hinfo):
                hinfo.forEach({ group in
                    print(group.gid ?? "no gid")
                })
                
            case .error(let error):
                print(error)
            case .completed:
                print("complete")
            }
        }.addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(tableViewScrollToBottom), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
}

extension ChatViewController {
    
    func keyboardChange(notification: Notification) {
        
        let userInfo = notification.userInfo
        
        let animationDuration = userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        let animationCurve = UIViewAnimationCurve(rawValue: userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! Int)!
        let keyboardEndFrame = userInfo?[UIKeyboardFrameEndUserInfoKey] as! CGRect
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(animationDuration)
        UIView.setAnimationCurve(animationCurve)
        
        // adjust ChatTableView's height
        if notification.name == Notification.Name.UIKeyboardWillShow {
            self.bottomConstraint.constant = keyboardEndFrame.size.height + 40
        } else {
            self.bottomConstraint.constant = 40
        }
        self.view.layoutIfNeeded()
        
        //adjust UUInputFunctionView's originPoint
        var newFrame = ifView.frame
        newFrame.origin.y = keyboardEndFrame.origin.y - newFrame.size.height
        ifView.frame = newFrame
        
        UIView.commitAnimations()
    }
    
    func tableViewScrollToBottom() {
        guard tableView.visibleCells.count > 0 else {
            return
        }
        let indexPath = IndexPath(row: tableView.visibleCells.count - 1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    
}
extension ChatViewController {
    
    func sendMessageForAudio(url: URL, duration: Int) {
        
        let strUUID = UUID().uuidString
        let path = String(format: "%@/Audio/%@.wav",(FileUtility.libraryCachesURL()!.path),strUUID)
        let nurl = URL(fileURLWithPath: path)
        print(nurl)
        
        // 检查目录并发送
        do {
            // 创建目录
            try FileManager.default.createDirectory(at: nurl.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            // 移动文件
//            try FileManager.default。moveItem(atPath: url, toPath: nurl)
            try FileManager.default.moveItem(at: url, to: nurl)
            
            //Convert to amr, then send to server
            if VoiceConverter.convertWav(toAmr: self.recordPath(name: String(format:"%@.wav", strUUID)), amrSavePath:self.recordPath(name: String(format:"%@.amr", strUUID))) == 0 {
                return
            }
            let urlAmr = URL(fileURLWithPath: self.recordPath(name: String(format:"%@.amr", strUUID)))
            
            
            var sendMessage = MoveIM.ImMessage()
            sendMessage.type = 1
            sendMessage.from = UserInfo.shared.id
            sendMessage.to = "15616530027750325535"
            sendMessage.content_type = 2
            sendMessage.ctime = Date()
            
            var fileInfo = MoveApi.FileInfo()
            fileInfo.type = "voice"
            fileInfo.duration = duration
            fileInfo.data = try Data(contentsOf: urlAmr)
            fileInfo.fileName = "voice.amr"
            fileInfo.mimeType = "voice/amr"
            FileStorageManager.share.upload(fileInfo: fileInfo).flatMapLatest { (fileup) -> Observable<MoveIM.ImMesageRsp> in
                sendMessage.content = fileup.fid
                return IMManager.shared.sendChatMessage(message: sendMessage)
                }.subscribe { event in
                    switch event {
                    case .next(let info):
                        print("local_id is \(info.local_id) msg id is \(info.msg_id)")
                        self.changeRecordFileName(strVoiceFile: String(format:"%@.amr", info.msg_id!), VoiceUrl: urlAmr)
                        self.changeRecordFileName(strVoiceFile: String(format:"%@.wav", info.msg_id!), VoiceUrl: nurl)
                    case .error(let error):
                        print(error.localizedDescription)
                    case .completed:
                        print("complete")
                    }
                }.addDisposableTo(disposeBag)
            
            
        } catch let e as NSError {
            // 发送失败
            //SIMLog.debug(e)
            print(e)
        }
    }
    
    func changeRecordFileName(strVoiceFile:String, VoiceUrl:URL){
        let nurl = URL(fileURLWithPath: String(format: "%@/Audio/%@", FileUtility.libraryCachesURL()!.path, strVoiceFile))
        
        // 检查目录并发送
        do {
            // 创建目录
            try FileManager.default.createDirectory(at: nurl.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            // 移动文件
            try FileManager.default.moveItem(at: VoiceUrl, to: nurl)
        } catch let e as NSError {
            // 发送失败
            //SIMLog.debug(e)
            print(e.description)
        }
    }
    
    func recordPath(name fileName: String) ->String {
        let filePath = String(format: "%@/Audio/%@", FileUtility.libraryCachesURL()!.path, fileName)
        
        if !FileManager.default.fileExists(atPath: filePath) {
            do {
                // 创建目录
                let nurl = URL(fileURLWithPath: filePath)
                try FileManager.default.createDirectory(at: nurl.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                
                // 创建文件
                FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
            } catch let e as NSError {
                //SIMLog.debug(e)
                print(e.description)
            }
        }
        
        return filePath
    }
}

extension ChatViewController: UUInputFunctionViewDelegate {
    
    func UUInputFunctionView(_ funcView: UUInputFunctionView, sendPicture image: UIImage) {
        self.chatModel.addMyPictureItem(image)
        self.tableView.reloadData()
        self.tableViewScrollToBottom()
    }
    
    func UUInputFunctionView(_ funcView: UUInputFunctionView, sendMessage message: String) {
        self.chatModel.addMyTextItem(message)
        self.tableView.reloadData()
        self.tableViewScrollToBottom()
    }
    
    func UUInputFunctionView(_ funcView: UUInputFunctionView, sendVoice voice: Data, time second: Int) {
        
        self.chatModel.addMyVoiceItem(voice, second: second)
        self.tableView.reloadData()
        self.tableViewScrollToBottom()
    }
    
    func UUInputFunctionView(_ funcView: UUInputFunctionView, sendURLForVoice URLForVoice: URL, duration second: Int) {
    
        self.sendMessageForAudio(url: URLForVoice, duration: second)
        
        do {
            let voice = try Data(contentsOf: URLForVoice)
            self.chatModel.addMyVoiceItem(voice, second: second)
            self.tableView.reloadData()
            self.tableViewScrollToBottom()
        } catch let e as NSError {
            //SIMLog.debug(e)
            print(e.description)
        }
        

    }
    
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatModel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellChatMessage", for: indexPath) as! UUMessageCell
        
        cell.delegate = self
        cell.messageFrame = chatModel.dataSource[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return chatModel.dataSource[indexPath.row].cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

extension ChatViewController: UUMessageCellDelegate {
    
}
