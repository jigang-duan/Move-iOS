//
//  ChatViewController.swift
//  UUChat
//
//  Created by jiang.duan on 2017/3/1.
//  Copyright © 2017年 jiang.duan. All rights reserved.
//

import UIKit

class ChatModel {
    
    var dataSource: [UUMessageFrame] = []
    var previousTime: Date? {
        return dataSource.last?.message.time
    }
    
    func addMyTextItem(_ text: String) {
        let URLStr = "http://img0.bdstatic.com/img/image/shouye/xinshouye/mingxing16.jpg"
        var message = UUMessage.myTextMessage(text, icon: URLStr, name: "Hello,Sister")
        message.minuteOffSet(start: message.time, end: previousTime ?? Date(timeIntervalSince1970: 0))
        dataSource.append(UUMessageFrame(message: message))
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.chatModel = ChatModel()
        self.view.addSubview(ifView)
        ifView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        ifView.bringSubview(toFront:tableView)
        
        let testResponse = IMManager.shared.initSyncKey().subscribe { info in
            switch info {
            case .next(let hinfo):
                print(hinfo)
            case .error(let error):
                print(error)
            case .completed:
                print("complete")

            }
        }
        print("reslut is ===testResponse%@",testResponse)
        
        var synList = ImSynckey()
        var list: [ImSynckey] = []
        synList.key = 1
        synList.value = 10000000
        list.append(synList)
        synList.key = 2
        synList.value = 20001234
        list.append(synList)
        synList.key = 3
        synList.value = 30001234
        list.append(synList)
        
        let testResponse1 = IMManager.shared.checkSyncKey(synckeyList: list).subscribe(<#T##observer: O##O#>)
        print("reslut is ===testResponse1%@",testResponse1)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /*NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)*/
        NotificationCenter.default.addObserver(self, selector: #selector(tableViewScrollToBottom), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
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
