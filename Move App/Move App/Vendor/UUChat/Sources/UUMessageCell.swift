//
//  UUMessageCell.swift
//  UUChat
//
//  Created by jiang.duan on 2017/3/2.
//  Copyright © 2017年 jiang.duan. All rights reserved.
//

import UIKit
import AVFoundation
import Kingfisher

@objc
protocol UUMessageCellDelegate {
    @objc optional func headImageDidClick(cell: UUMessageCell, userId: String)
    @objc optional func cellContentDidClick(cell: UUMessageCell, image contentImage: UIImage)
}


class UUMessageCell: UITableViewCell {

    lazy var labelTime: UILabel = {
        let $ = UILabel()
        $.textAlignment = .center
        $.textColor = UIColor.gray
        $.font = ChatTimeFont
        return $
    }()
    
    lazy var labelNum: UILabel = {
        let $ = UILabel()
        $.textColor = UIColor.gray
        $.textAlignment = .center
        $.font = ChatTimeFont
        return $
    }()
    
    lazy var headImageBackView: UIView = {
        let $ = UIView()
        $.layer.cornerRadius = 22
        $.layer.masksToBounds = true
        $.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
        return $
    }()
    
    lazy var btnHeadImage: UIButton = {
        let $ = UIButton(type: .custom)
        $.layer.cornerRadius = 20
        $.layer.masksToBounds = true
        return $
    }()
    
    lazy var btnContent: UUMessageContentButton = {
        let $ = UUMessageContentButton(type: .custom)
        $.setTitleColor(UIColor.black, for: .normal)
        $.titleLabel?.font = ChatContentFont
        $.titleLabel?.numberOfLines = 0
        return $
    }()
    
    var messageFrame: UUMessageFrame! {
        didSet {
            let message = messageFrame.message
            
            // 1、设置时间
            self.labelTime.text = message.strTime
            self.labelTime.frame = messageFrame.timeF
            
            // 2、设置头像
            headImageBackView.frame = messageFrame.iconF
            self.btnHeadImage.frame = CGRect(x: 2, y: 2, width: ChatIconWH-4, height: ChatIconWH-4)
            _ = self.btnHeadImage.kf.setBackgroundImage(with: URL(string: message.icon),
                                                    for: .normal,
                                                    placeholder: UIImage(named: "headImage.jpeg"),
                                                    options: [.transition(ImageTransition.fade(1))],
                                                    progressBlock: nil,
                                                    completionHandler: nil)
            
            // 3、设置下标
            self.labelNum.text = message.name
            if messageFrame.nameF.origin.x > 160 {
                self.labelNum.frame = CGRect(x: messageFrame.nameF.origin.x - 50,
                                             y: messageFrame.nameF.origin.y + 3 ,
                                             width: 100,
                                             height: messageFrame.nameF.size.height)
                self.labelNum.textAlignment = .right
            } else {
                self.labelNum.frame = CGRect(x: messageFrame.nameF.origin.x,
                                             y: messageFrame.nameF.origin.y + 3 ,
                                             width: 80,
                                             height: messageFrame.nameF.size.height)
                self.labelNum.textAlignment = .left
            }
            
            // 4、设置内容
            self.btnContent.setTitle("", for: .normal)
            self.btnContent.voiceBackView.isHidden = true
            self.btnContent.backImageView.isHidden = true
            
            self.btnContent.frame = messageFrame.contentF
            
            if message.from == .me {
                self.btnContent.isMyMessage = true
                self.btnContent.setTitleColor(UIColor.white, for: .normal)
                self.btnContent.contentEdgeInsets = UIEdgeInsetsMake(ChatContentTop, ChatContentRight, ChatContentBottom, ChatContentLeft)
            } else {
                self.btnContent.isMyMessage = false
                self.btnContent.setTitleColor(UIColor.gray, for: .normal)
                self.btnContent.contentEdgeInsets = UIEdgeInsetsMake(ChatContentTop, ChatContentLeft, ChatContentBottom, ChatContentRight)
            }
            
            //背景气泡图
            var normal: UIImage
            if message.from == .me {
                normal = UIImage(named: "chatto_bg_normal")!
                normal = normal.resizableImage(withCapInsets: UIEdgeInsetsMake(35, 10, 10, 22))
            } else {
                normal = UIImage(named: "chatfrom_bg_normal")!
                normal = normal.resizableImage(withCapInsets: UIEdgeInsetsMake(35, 22, 10, 10))
            }
            self.btnContent.setBackgroundImage(normal, for: .normal)
            self.btnContent.setBackgroundImage(normal, for: .highlighted)
            
            switch message.type {
            case .text:
                self.btnContent.setTitle(message.content.text, for: .normal)
            case .picture:
                self.btnContent.backImageView.isHidden = false
                if let image = message.content.picture?.image {
                    self.btnContent.backImageView.image = image
                } else {
                    self.btnContent.backImageView.kf.setImage(with: URL(string: message.content.picture?.url ?? ""))
                }
                self.btnContent.backImageView.frame = CGRect(x: 0, y: 0,
                                                             width: self.btnContent.frame.size.width,
                                                             height: self.btnContent.frame.size.height)
                self.makeMaskView(self.btnContent.backImageView, with: normal)
            case .voice:
                self.btnContent.voiceBackView.isHidden = false
                self.btnContent.second.text = String(format: "%d's Voice", message.content.voice?.second ?? 0)
                voiceURL = message.content.voice?.url
            default:
                break
            }
            
        }
    }
    
    @IBOutlet weak var delegate: UUMessageCellDelegate?
    
    private var audio: UUAVAudioPlayer?
    
    private var songData: Data?
    private var voiceURL: String?
    fileprivate var contentVoiceIsPlaying = false
    
    fileprivate var imageAvatarBrowser: UUImageAvatarBrowser!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.steupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.steupViews()
    }
    
    private func steupViews() {
        
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        
        // 1、创建时间
        self.contentView.addSubview(labelTime)
        
        // 2、创建头像
        self.contentView.addSubview(headImageBackView)
        self.headImageBackView.addSubview(btnHeadImage)
        self.btnHeadImage.addTarget(self, action: #selector(btnHeadImageClick(_:)), for: .touchUpInside)
        
        // 3、创建头像下标
        self.contentView.addSubview(labelTime)
        
        // 4、创建内容
        self.contentView.addSubview(btnContent)
        btnContent.addTarget(self, action: #selector(btnContentClick), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(UUAVAudioPlayerDidFinishPlay), name: NSNotification.Name("VoicePlayHasInterrupt"), object: nil)
        
        //红外线感应监听
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sensorStateChange(notification:)),
                                               name: NSNotification.Name.UIDeviceProximityStateDidChange,
                                               object: nil)
        
        contentVoiceIsPlaying = false
        imageAvatarBrowser = UUImageAvatarBrowser()
    }
    
    // 头像点击
    @objc private func btnHeadImageClick(_ sender: UIButton) {
        self.delegate?.headImageDidClick?(cell: self, userId: self.messageFrame.message.msgId)
    }
    
    // 内容点击
    @objc private func btnContentClick() {
        // play audio
        if self.messageFrame.message.type == .voice {
            if !contentVoiceIsPlaying {
                NotificationCenter.default.post(name: NSNotification.Name("VoicePlayHasInterrupt"), object: nil)
                contentVoiceIsPlaying = true
                self.audio = UUAVAudioPlayer.shared
                self.audio?.delegate = self
                if let data = self.songData {
                    self.audio?.play(songData: data)
                } else if let url = self.voiceURL {
                    self.audio?.play(songUrl: url)
                }
            } else {
                self.UUAVAudioPlayerDidFinishPlay()
            }
        }
        // show the picture
        else if self.messageFrame.message.type == .picture {
            if self.btnContent.backImageView.image != nil {
                imageAvatarBrowser.showImage(avatarImageView: self.btnContent.backImageView)
            }
            if let vc = self.delegate as? UIViewController {
                vc.view.endEditing(true)
            }
            if let image = self.btnContent.backImageView.image {
                self.delegate?.cellContentDidClick?(cell: self, image: image)
            }
        }
        // show text and gonna copy that
        else if self.messageFrame.message.type == .text {
            self.btnContent.becomeFirstResponder()
            let menu = UIMenuController.shared
            menu.setTargetRect(self.btnContent.frame, in: self.btnContent.superview!)
            menu.setMenuVisible(true, animated: true)
        }
    }
    
    private func makeMaskView(_ view: UIView, with image: UIImage) {
        let imageViewMask = UIImageView(image: image)
        imageViewMask.frame = view.frame.insetBy(dx: 0.0, dy: 0.0)
        view.layer.mask = imageViewMask.layer
    }
}

extension UUMessageCell {
    
    // 处理监听触发事件
    func sensorStateChange(notification: NotificationCenter) {
        if UIDevice.current.proximityState == true {
            print("Device is close to user")
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        } else {
            print("Device is not close to user")
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
    }
}


extension UUMessageCell: UUAVAudioPlayerDelegate {
    
    func UUAVAudioPlayerBeiginLoadVoice() {
        self.btnContent.benginLoadVoice()
    }
    
    func UUAVAudioPlayerBeiginPlay() {
        // 开启红外线感应
        UIDevice.current.isProximityMonitoringEnabled = true
        self.btnContent.didLaodVoice()
    }
    
    func UUAVAudioPlayerDidFinishPlay() {
        // 关闭红外线感应
        UIDevice.current.isProximityMonitoringEnabled = false
        contentVoiceIsPlaying = true
        self.btnContent.stopPlay()
        UUAVAudioPlayer.shared.stop()
    }
}
