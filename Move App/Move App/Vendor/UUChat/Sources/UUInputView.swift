//
//  UUInputView.swift
//  Move App
//
//  Created by jiang.duan on 2017/3/25.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

@objc
protocol UUInputViewDelegate {
    @objc optional func UUInputView(_ inputView: UUInputView, sendEmoji emoji: String)
    @objc optional func UUInputView(_ inputView: UUInputView, sendURLForVoice URLForVoice: URL, duration second: Int)
    @objc optional func UUInputView(_ inputView: UUInputView, isUnfold: Bool)
}

class UUInputView: UIView {
    
    lazy var btnSendEmoji: UIButton = {
        let $ = UIButton(type: .custom)
        $.frame = CGRect(x: Main_Screen_Width-40, y: 5, width: 30, height: 30)
        $.setTitle("", for: .normal)
        $.setBackgroundImage(UIImage(named: "message_emotion"), for: .normal)
        $.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        return $
    }()
    
    lazy var btnVoiceRecord: UIButton = {
        let $ = UIButton(type: .custom)
        $.frame = CGRect(x: 20, y: 5, width: Main_Screen_Width-90, height: 30)
        $.setBackgroundImage(UIImage(named: "chat_message_back"), for: .normal)
        $.setTitleColor(UIColor(red: 0.0, green: 0.619607865810394, blue: 1.0, alpha: 1.0), for: .normal)
        $.setTitleColor(UIColor(red: 0.0, green: 0.619607865810394, blue: 1.0, alpha: 0.5), for: UIControlState.highlighted)
        $.setTitle("Hold to Talk", for: .normal)
        $.setTitle("Release to Send", for: .highlighted)
        return $
    }()
    
    lazy var emojiView: ISEmojiView = {
        let $ = ISEmojiView()
        return $
    }()
    
    
    @IBOutlet weak var superVC: UIViewController!
    @IBOutlet var delegate: UUInputViewDelegate?
    
    fileprivate var isUnfoldEmoji = false
    
    fileprivate var Amr: AmrRecorder!
    fileprivate var isbeginVoiceRecord = false
    fileprivate var _playTime = 0
    fileprivate var playTimer: Timer?
    
    convenience init(superVC: UIViewController) {
        let frame = defaultFrame
        self.init(frame: frame)
        self.superVC = superVC
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.Amr = AmrRecorder(delegate: self)
        self.backgroundColor = UIColor.white
        
        //发送Emoji
        self.addSubview(btnSendEmoji)
        btnSendEmoji.addTarget(self, action: #selector(emojiRecord(_:)), for: .touchUpInside)
        
        // 语音录入键
        self.addSubview(btnVoiceRecord)
        btnVoiceRecord.addTarget(self, action: #selector(beginrecordVoice(_:)), for: .touchDown)
        btnVoiceRecord.addTarget(self, action: #selector(endRecordVoice(_:)), for: .touchUpInside)
        btnVoiceRecord.addTarget(self, action: #selector(cancelRecordVoice(_:)), for: .touchUpOutside)
        btnVoiceRecord.addTarget(self, action: #selector(cancelRecordVoice(_:)), for: .touchCancel)
        btnVoiceRecord.addTarget(self, action: #selector(remindDragExit(_:)), for: .touchDragExit)
        btnVoiceRecord.addTarget(self, action: #selector(remindDragEnter(_:)), for: .touchDragEnter)
        
        // Emoji
        self.addSubview(emojiView)
        emojiView.delegate = self
        
        // 分割线
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let frame = defaultFrame
        self.init(frame: frame)
    }
}


// MARK:  录音touch事件
extension UUInputView {
    
    func beginrecordVoice(_ sender: UIButton?) {
        Amr.startRecord()
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
            Amr.stopRecord()
            playTimer?.invalidate()
            playTimer = nil
        }
    }
    
    func cancelRecordVoice(_ sender: UIButton) {
        if playTimer != nil {
            Amr.cancelRecord()
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
        if _playTime >= 60 {
            self.endRecordVoice(nil)
        }
    }
}

extension UUInputView: AmrRecorderDelegate {
    
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
    func endAmrConvert(ofFile amrPath: String!) {
        let voiceURL = URL(fileURLWithPath: amrPath)
        self.delegate?.UUInputView?(self, sendURLForVoice: voiceURL, duration: _playTime + 1)
        UUProgressHUD.dismiss(withSuccess: "Success")
        
        //缓冲消失时间 (最好有block回调消失完成)
        self.btnVoiceRecord.isEnabled = false
        DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime(timespec: timespec(tv_sec: 0, tv_nsec: Int(NSEC_PER_SEC))), execute: {
            self.btnVoiceRecord.isEnabled = true
        })
    }
    
    func endWavConvert(ofFile wavPath: String!) {
    }
}

extension UUInputView: ISEmojiViewDelegate {
    
    func emojiViewDidSelectEmoji(emojiView: ISEmojiView, emoji: EmojiType) {
        isUnfoldEmoji = false
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = defaultFrame
        })
        self.delegate?.UUInputView?(self, sendEmoji: emoji.rawValue)
    }
    
    func emojiViewDidPressDeleteButton(emojiView: ISEmojiView) {
    }
}


extension UUInputView {
    
    func shrinkEmoji() {
        if isUnfoldEmoji {
            unfoldEmoji()
        }
    }
    
    private func unfoldEmoji() {
        isUnfoldEmoji = !isUnfoldEmoji
        UIView.animate(withDuration: 0.6, animations: {
            self.frame = self.isUnfoldEmoji ? unfoldFrame : defaultFrame
        })
        self.delegate?.UUInputView?(self, isUnfold: isUnfoldEmoji)
    }
    
    @objc fileprivate func emojiRecord(_ sender: UIButton) {
        unfoldEmoji()
    }
}


fileprivate let defaultFrame = CGRect(x: 0, y: Main_Screen_Height - 40 - 64, width: Main_Screen_Width, height: 40)
fileprivate let unfoldFrame  = CGRect(x: 0, y: Main_Screen_Height - 168 - 64, width: Main_Screen_Width, height: 168)

fileprivate let Main_Screen_Height = UIScreen.main.bounds.size.height
fileprivate let Main_Screen_Width = UIScreen.main.bounds.size.width
