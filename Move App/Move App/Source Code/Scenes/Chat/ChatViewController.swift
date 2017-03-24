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




class ChatViewController: UIViewController {

    @IBOutlet weak var ifView: UUInputFunctionView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var chatModel: ChatViewModel!
    var disposeBag = DisposeBag()
    
    var message: MessageEntity?
    
    var messageFramesVariable: Variable<[UUMessageFrame]> = Variable([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.chatModel = ChatViewModel()
        self.view.addSubview(ifView)
        ifView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self

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
            
            
             self.chatModel.addVoiceItemByURL(urlAmr, second: duration)
            let message = MessageEntity()
            message.from = Me.shared.user.id
            message.to = DeviceManager.shared.currentDevice?.user?.uid
            message.groupId = nil//DeviceManager.shared.currentDevice?.user?.gid
            message.content = nurl.absoluteString
            message.contentType = MessageEntity.ContentType.voice.rawValue
            message.readStatus = MessageEntity.ReadStatus.sending.rawValue
            message.duration = TimeInterval(duration)
            message.createDate = Date()
            
            Observable.from([message]).subscribe(Realm.rx.add())
            
            
            
            let data = try Data(contentsOf: urlAmr)
            FSManager.shared.uploadVoice(with: data, duration: duration)
                .takeLast(1)
                .map{$0.fid}
                .filterNil()
                .flatMapLatest({ fid -> Observable<MoveIM.ImMesageRsp> in
                    var sendMessage = MoveIM.ImMessage()
//                    sendMessage.type = 1
                    sendMessage.from = UserInfo.shared.id
                    sendMessage.to = DeviceManager.shared.currentDevice?.user?.uid
                    sendMessage.content_type = 3
                    sendMessage.ctime = Date()
                    sendMessage.content = fid
//                    message.content = fid
                    return IMManager.shared.sendChatMessage(message: sendMessage).debug()
                }).debug()
                .bindNext({ info in
                    self.changeRecordFileName(strVoiceFile: String(format:"%@.amr", info.msg_id!), VoiceUrl: urlAmr)
                    self.changeRecordFileName(strVoiceFile: String(format:"%@.wav", info.msg_id!), VoiceUrl: nurl)
//                    message.id = info.msg_id
                })
                .addDisposableTo(disposeBag)
            
            
            
            
            
        
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
//        self.chatModel.addMyPictureItem(image)
//        self.tableView.reloadData()
//        self.tableViewScrollToBottom()
    }
    
    func UUInputFunctionView(_ funcView: UUInputFunctionView, sendMessage message: String) {
//        self.chatModel.addMyTextItem(message)
//        self.tableView.reloadData()
//        self.tableViewScrollToBottom()
    }
    
    func UUInputFunctionView(_ funcView: UUInputFunctionView, sendVoice voice: Data, time second: Int) {
        
//        self.chatModel.addMyVoiceItem(voice, second: second)
//        self.tableView.reloadData()
//        self.tableViewScrollToBottom()
    }
    
    func UUInputFunctionView(_ funcView: UUInputFunctionView, sendURLForVoice URLForVoice: URL, duration second: Int) {
//        self.chatModel.dataSource.sort(by: <#T##(UUMessageFrame, UUMessageFrame) -> Bool#>)
        self.sendMessageForAudio(url: URLForVoice, duration: second)
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
