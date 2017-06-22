//
//  UUInputFunctionView.swift
//  UUChat
//
//  Created by jiang.duan on 2017/3/3.
//  Copyright © 2017年 jiang.duan. All rights reserved.
//

import UIKit

@objc
protocol UUInputFunctionViewDelegate {
    @objc optional func UUInputFunctionView(_ funcView: UUInputFunctionView, sendMessage message: String)
    @objc optional func UUInputFunctionView(_ funcView: UUInputFunctionView, sendPicture image: UIImage)
    @objc optional func UUInputFunctionView(_ funcView: UUInputFunctionView, sendVoice voice: Data, time second: Int)
    @objc optional func UUInputFunctionView(_ funcView: UUInputFunctionView, sendURLForVoice URLForVoice: URL, duration second: Int)
}

class UUInputFunctionView: UIView {
    
    lazy var btnSendMessage: UIButton = {
        let $ = UIButton(type: .custom)
        $.frame = CGRect(x: Main_Screen_Width-40, y: 5, width: 30, height: 30)
        $.setTitle("", for: .normal)
        $.setBackgroundImage(UIImage(named: "Chat_take_picture"), for: .normal)
        $.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        return $
    }()

    lazy var btnChangVoiceState: UIButton = {
        let $ = UIButton(type: .custom)
        $.frame = CGRect(x: 5, y: 5, width: 30, height: 30)
        $.setBackgroundImage(UIImage(named: "chat_voice_record"), for: .normal)
        $.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        return $
    }()
    
    lazy var btnVoiceRecord: UIButton = {
        let $ = UIButton(type: .custom)
        $.frame = CGRect(x: 70, y: 5, width: Main_Screen_Width-70*2, height: 30)
        $.isHidden = true
        $.setBackgroundImage(UIImage(named: "chat_message_back"), for: .normal)
        $.setTitleColor(UIColor.lightGray, for: .normal)
        $.setTitleColor(UIColor.lightGray.withAlphaComponent(0.5), for: UIControlState.highlighted)
        $.setTitle("Hold to Talk", for: .normal)
        $.setTitle("Release to Send", for: .highlighted)
        return $
    }()
    
    lazy var textViewInput: UITextView = {
        let $ = UITextView(frame: CGRect(x: 45, y: 5, width: Main_Screen_Width-2*45, height: 30))
        $.layer.cornerRadius = 4
        $.layer.masksToBounds = true
        $.layer.borderWidth = 1
        $.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
        return $
    }()
    
    var isAbleToSendTextMessage = false
    
    @IBOutlet var superVC: UIViewController!
    @IBOutlet var delegate: UUInputFunctionViewDelegate?
    
    
    fileprivate var isbeginVoiceRecord = false
    fileprivate var MP3: Mp3Recorder!
    fileprivate var _playTime = 0
    fileprivate var playTimer: Timer?
    
    fileprivate lazy var placeHold: UILabel = {
        let $ = UILabel(frame: CGRect(x: 20, y: 0, width: 200, height: 30))
        $.text = "Input the contents here"
        $.textColor = UIColor.lightGray.withAlphaComponent(0.8)
        return $
    }()
    
    convenience init(superVC: UIViewController) {
        let frame = CGRect(x: 0, y: Main_Screen_Height - 40 - 64, width: Main_Screen_Width, height: 40)
        self.init(frame: frame)
        self.superVC = superVC
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.MP3 = Mp3Recorder(delegate: self)
        self.backgroundColor = UIColor.white
        
        //发送消息
        self.addSubview(btnSendMessage)
        btnSendMessage.addTarget(self, action: #selector(sendMessage(_:)), for: .touchUpInside)
        
        // 改变状态（语音、文字）
        self.addSubview(btnChangVoiceState)
        btnChangVoiceState.addTarget(self, action: #selector(voiceRecord(_:)), for: .touchUpInside)
        
        // 语音录入键
        self.addSubview(btnVoiceRecord)
        btnVoiceRecord.addTarget(self, action: #selector(beginrecordVoice(_:)), for: .touchDown)
        btnVoiceRecord.addTarget(self, action: #selector(endRecordVoice(_:)), for: .touchUpInside)
        btnVoiceRecord.addTarget(self, action: #selector(cancelRecordVoice(_:)), for: .touchUpOutside)
        btnVoiceRecord.addTarget(self, action: #selector(cancelRecordVoice(_:)), for: .touchCancel)
        btnVoiceRecord.addTarget(self, action: #selector(remindDragExit(_:)), for: .touchDragExit)
        btnVoiceRecord.addTarget(self, action: #selector(remindDragEnter(_:)), for: .touchDragEnter)
        
        // 输入框
        self.addSubview(textViewInput)
        textViewInput.delegate = self
        
        // 输入框的提示语
        self.textViewInput.addSubview(placeHold)
        
        // 分割线
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        
        // 添加通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textViewDidEndEditing(_:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let frame = CGRect(x: 0, y: Main_Screen_Height - 40 - 64, width: Main_Screen_Width, height: 40)
        self.init(frame: frame)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


// MARK: UITextView Delegate
extension UUInputFunctionView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeHold.isHidden = self.textViewInput.text.characters.count > 0
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.changeSendBtnWithPhoto(textView.text.characters.count <= 0)
        placeHold.isHidden = textView.text.characters.count > 0
    }
    
    fileprivate func changeSendBtnWithPhoto(_ isPhoto: Bool) {
        self.isAbleToSendTextMessage = !isPhoto
        self.btnSendMessage.setTitle(isPhoto ? "" : "send", for: .normal)
        self.btnSendMessage.frame = RECT_CHANGE_width(self.btnSendMessage, isPhoto ?  30.0 : 35.0)
        let image = UIImage(named: isPhoto ? "Chat_take_picture" : "chat_send_message")
        btnSendMessage.setBackgroundImage(image, for: .normal)
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        placeHold.isHidden = self.textViewInput.text.characters.count > 0
    }
    
    fileprivate func changeSendBtnToPhoto() {
        changeSendBtnWithPhoto(true)
        textViewInput.text = ""
        placeHold.isHidden = self.textViewInput.text.characters.count > 0
    }

}

// MARK:  录音touch事件
extension UUInputFunctionView {
    
    func beginrecordVoice(_ sender: UIButton?) {
        MP3.startRecord()
        _playTime = 0
        playTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                         target: self,
                                         selector: #selector(countVoiceTime),
                                         userInfo: nil,
                                         repeats: true)
        UUProgressHUD.show()
    }
    
    func endRecordVoice(_ sender: UIButton?) {
        if playTimer != nil {
            MP3.stopRecord()
            playTimer?.invalidate()
            playTimer = nil
        }
    }
    
    func cancelRecordVoice(_ sender: UIButton) {
        if playTimer != nil {
            MP3.cancelRecord()
            playTimer?.invalidate()
            playTimer = nil
        }
        UUProgressHUD.dismissWithError("Cancel")
    }
    
    func remindDragExit(_ sender: UIButton) {
        UUProgressHUD.changeSubTitle("Release to cancel")
    }
    
    func remindDragEnter(_ sender: UIButton) {
        UUProgressHUD.changeSubTitle("Slide up to cancel")
    }
    
    func countVoiceTime() {
        _playTime = _playTime + 1
        if _playTime >= 30 {
            self.endRecordVoice(nil)
        }
    }
}

extension UUInputFunctionView {
    // 改变输入与录音状态
    @objc fileprivate func voiceRecord(_ sender: UIButton) {
        
        self.btnVoiceRecord.isHidden = !self.btnVoiceRecord.isHidden
        self.textViewInput.isHidden = !self.textViewInput.isHidden
        isbeginVoiceRecord = !isbeginVoiceRecord
        if isbeginVoiceRecord {
            btnChangVoiceState.setBackgroundImage(UIImage(named: "chat_ipunt_message"), for: .normal)
            textViewInput.resignFirstResponder()
        } else {
            btnChangVoiceState.setBackgroundImage(UIImage(named: "chat_voice_record"), for: .normal)
            textViewInput.becomeFirstResponder()
        }
    }
    
    // 发送消息（文字图片）
    @objc fileprivate func sendMessage(_ sender: UIButton) {
        
        if self.isAbleToSendTextMessage {
            let resultStr = self.textViewInput.text.replacingOccurrences(of: "   ", with: "")
            self.delegate?.UUInputFunctionView?(self, sendMessage: resultStr)
            textViewInput.resignFirstResponder()
            self.changeSendBtnToPhoto()
            
        } else {
            self.textViewInput.resignFirstResponder()
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
                self.addCarema()
            }
            let imagesAction = UIAlertAction(title: "Images", style: .default) { _ in
                self.openPicLibrary()
            }
            UUInputWireframe.presentActionSheet(actions: [cameraAction, imagesAction])
        }
    }
}

extension UUInputFunctionView: Mp3RecorderDelegate {
    
    func failRecord() {
        UUProgressHUD.dismiss(withSuccess: "Too short")
        
        //缓冲消失时间 (最好有block回调消失完成)
        self.btnVoiceRecord.isEnabled = false
        DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime(timespec: timespec(tv_sec: 0, tv_nsec: Int(NSEC_PER_SEC))), execute: {
            self.btnVoiceRecord.isEnabled = true
        })
    }
    
    func beginConvert() {
    }
    
    //回调录音资料
    func endConvert(with voiceData: Data!) {
        
        self.delegate?.UUInputFunctionView?(self, sendVoice: voiceData, time: _playTime + 1)
        UUProgressHUD.dismiss(withSuccess: "Success")
        
        //缓冲消失时间 (最好有block回调消失完成)
        self.btnVoiceRecord.isEnabled = false
        DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime(timespec: timespec(tv_sec: 0, tv_nsec: Int(NSEC_PER_SEC))), execute: {
            self.btnVoiceRecord.isEnabled = true
        })
    }
    
    func endCafConvert(with voiceURL: URL!) {
        Logger.debug("voiceURL\(voiceURL)")
        self.delegate?.UUInputFunctionView?(self, sendURLForVoice: voiceURL, duration: _playTime + 1)
        UUProgressHUD.dismiss(withSuccess: "Success")
        
        //缓冲消失时间 (最好有block回调消失完成)
        self.btnVoiceRecord.isEnabled = false
        DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime(timespec: timespec(tv_sec: 0, tv_nsec: Int(NSEC_PER_SEC))), execute: {
            self.btnVoiceRecord.isEnabled = true
        })

    }
}

extension UUInputFunctionView {
    
    func addCarema() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = .camera
            self.superVC.present(picker, animated: true, completion: nil)
        } else {
            //如果没有提示用户
            UUInputWireframe.presentAlert(title: "Tip", message: "Your device don't have camera")
        }
    }
    
    func openPicLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = .photoLibrary
            self.superVC.present(picker, animated: true, completion: nil)
        }
    }
    
}

extension UUInputFunctionView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editImege = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.superVC.dismiss(animated: true) {
                self.delegate?.UUInputFunctionView?(self, sendPicture: editImege)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.superVC.dismiss(animated: true, completion: nil)
    }
}


class UUInputWireframe {
    static let shared = UUInputWireframe()
    
    private static func rootViewController() -> UIViewController {
        // cheating, I know
        return UIApplication.shared.keyWindow!.rootViewController!
    }
    
    static func presentActionSheet(actions: [UIAlertAction]) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
        })
        for action in actions {
            actionSheet.addAction(action)
        }
        rootViewController().present(actionSheet, animated: true, completion: nil)
    }
    
    static func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Sure", style: .cancel) { _ in
        })
        
        rootViewController().present(alert, animated: true, completion: nil)
    }

}

fileprivate let Main_Screen_Height = UIScreen.main.bounds.size.height
fileprivate let Main_Screen_Width = UIScreen.main.bounds.size.width

fileprivate func RECT_CHANGE_width(_ v: UIView, _ w: CGFloat) -> CGRect {
    return CGRect(x: X(v), y: Y(v), width: w, height: HEIGHT(v))
}

fileprivate func X(_ v: UIView) -> CGFloat {
    return v.frame.origin.x
}
fileprivate func Y(_ v: UIView) -> CGFloat {
    return v.frame.origin.y
}
fileprivate func WIDTH(_ v: UIView) -> CGFloat {
    return v.frame.size.width
}
fileprivate func HEIGHT(_ v: UIView) -> CGFloat {
    return v.frame.size.height
}

