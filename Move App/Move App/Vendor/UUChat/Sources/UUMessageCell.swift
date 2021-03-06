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
import SwiftGifOrigin
import CustomViews

@objc
protocol UUMessageCellDelegate {
    @objc optional func headImageDidClick(cell: UUMessageCell, userId: String)
    @objc optional func cellContentDidClick(cell: UUMessageCell, image contentImage: UIImage)
    @objc optional func cellContentDidClick(cell: UUMessageCell, voice messageId: String)
}


@objc
protocol UUMessageCellMenuDelegate {
    @objc optional func handleMenu(cell: UUMessageCell, menuItem title: String, at index: Int)
}

class UUMessageCell: UITableViewCell {
    
    static let MenuItem_Delete = "Delete"
    static let MenuItem_More = "More"

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
        $.numberOfLines = 2
        return $
    }()
    
    lazy var headImageBackView: UIView = {
        let $ = UIView()
        $.layer.cornerRadius = ChatIconWH / 2
        $.layer.masksToBounds = true
        $.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
        return $
    }()
    
    lazy var btnHeadImage: UIButton = {
        let $ = UIButton(type: .custom)
        $.layer.cornerRadius = (ChatIconWH-ChatIconBorder)/2
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
    
    lazy var badgeView: UIView = {
        let $ = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 6.0, height: 6.0)))
        $.backgroundColor = UIColor.red
        $.layer.cornerRadius = 3.0
        $.layer.masksToBounds = true
        return $
    }()
    
    lazy var indicator: UIActivityIndicatorView = {
        let $ = UIActivityIndicatorView(activityIndicatorStyle: .white)
        //$.center = CGPoint(x: 85, y: 15)
        $.isUserInteractionEnabled = false
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
            self.btnHeadImage.frame = CGRect(x: ChatIconBorder/2, y: ChatIconBorder/2, width: ChatIconWH-ChatIconBorder, height: ChatIconWH-ChatIconBorder)
            let placeImg = CDFInitialsAvatar(
                rect: CGRect(x: 0, y: 0, width: btnHeadImage.frame.width, height: btnHeadImage.frame.height),
                fullName: message.name)
                .imageRepresentation()!
            _ = self.btnHeadImage.kf.setBackgroundImage(with: URL(string: message.icon),
                                                    for: .normal,
                                                    placeholder: UIImage(named: message.icon) ?? placeImg,
                                                    options: [.transition(ImageTransition.fade(1))],
                                                    progressBlock: nil,
                                                    completionHandler: nil)
            
            // 3、设置下标
            self.labelNum.text = message.name
            if messageFrame.nameF.origin.x > 160 {
                self.labelNum.frame = CGRect(x: messageFrame.nameF.origin.x - 3,
                                             y: messageFrame.nameF.origin.y + 3 ,
                                             width: messageFrame.nameF.size.width,
                                             height: messageFrame.nameF.size.height)
                self.labelNum.textAlignment = .center
            } else {
                self.labelNum.frame = CGRect(x: messageFrame.nameF.origin.x,
                                             y: messageFrame.nameF.origin.y + 3 ,
                                             width: messageFrame.nameF.size.width,
                                             height: messageFrame.nameF.size.height)
                self.labelNum.textAlignment = .center
            }
            
            // 4、设置内容
            self.btnContent.setTitle("", for: .normal)
            self.btnContent.voiceBackView.isHidden = true
            self.btnContent.backImageView.isHidden = true
            
            self.btnContent.frame = messageFrame.contentF
            self.badgeView.frame = messageFrame.badgeF
            self.indicator.center = messageFrame.indicatorP
            
            self.badgeView.isHidden = true
            
            if message.isFailure {
                self.indicator.isHidden = false
                self.indicator.startAnimating()
            } else {
                self.indicator.stopAnimating()
                self.indicator.isHidden = true
            }
            
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
                normal = UIImage(named: "message_talk_bg_right")!
                normal = normal.resizableImage(withCapInsets: UIEdgeInsetsMake(15, 10, 10, 12))
            } else {
                normal = UIImage(named: "message_talk_bg")!
                normal = normal.resizableImage(withCapInsets: UIEdgeInsetsMake(15, 22, 10, 10))
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
                self.btnContent.second.text = String(format: "%d\" ", message.content.voice?.second ?? 0)
                voiceURL = message.content.voice?.url
                if message.from == .other {
                    self.badgeView.isHidden = (message.state == .read)
                    self.btnContent.voice.image = UIImage(named: "message_listen_eachother")
                } else {
                    self.btnContent.voice.image = UIImage(named: "message_listen_me")
                    self.btnContent.second.textColor = UIColor(red: 0.0, green: 0.62, blue: 1.0, alpha: 1.0)
                }
                
            case .emoji:
                if let emoji = message.content.emoji {
                    self.btnContent.backImageView.isHidden = false
                    self.btnContent.backImageView.load(emoji: emoji)
                }
                self.btnContent.backImageView.frame = CGRect(x: ChatContentLeft, y: ChatContentTop,
                                                             width: ChatEmojiWH,
                                                             height: ChatEmojiWH)
                //self.makeMaskView(self.btnContent.backImageView, with: normal)
            default:
                break
            }
            
        }
    }
    
    @IBOutlet weak var delegate: UUMessageCellDelegate?
    @IBOutlet weak var menuDelegate: UUMessageCellMenuDelegate?
    var index: Int?
    
    private var audio: UUAVAudioPlayer?
    
    private var songData: Data?
    private var voiceURL: URL?
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if self.isEditing {
            for subview in self.subviews {
                if (subview is UIControl) && (subview.subviews.count == 1) {
                    if let image = subview.subviews.first as? UIImageView {
                        image.image = selected ? UIImage(named: "general_del_pre") : UIImage(named: "general_del_nor")
                        break
                    }
                }
            }
        }
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
        self.contentView.addSubview(labelNum)
        
        // 4、创建内容
        self.contentView.addSubview(btnContent)
        btnContent.addTarget(self, action: #selector(btnContentClick), for: .touchUpInside)
        
        // 红点
        self.contentView.addSubview(badgeView)
        
        // indicator
        self.contentView.addSubview(indicator)
        
        NotificationCenter.default.addObserver(self, selector: #selector(UUAVAudioPlayerDidFinishPlay), name: NSNotification.Name("VoicePlayHasInterrupt"), object: nil)
        
        //红外线感应监听
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sensorStateChange(notification:)),
                                               name: NSNotification.Name.UIDeviceProximityStateDidChange,
                                               object: nil)
        
        contentVoiceIsPlaying = false
        imageAvatarBrowser = UUImageAvatarBrowser()
        
        // Menu
        let itDelete = UIMenuItem(title: R.string.localizable.id_str_remove_alarm_title(), action: #selector(handleDeleteMenu(_:)))
        let itMore = UIMenuItem(title: R.string.localizable.id_more(), action: #selector(handleMoreMenu(_:)))
        let itTurnOnSpeaker = UIMenuItem(title: speekerDescription, action: #selector(handleSpeakerMenu(_:)))
        
        let menu = UIMenuController.shared
        menu.menuItems = [itTurnOnSpeaker, itDelete, itMore]
        menu.update()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        btnContent.addGestureRecognizer(longPress)
    }
    
    @objc private func longPress(_ recongnizer: UILongPressGestureRecognizer) {
        if recongnizer.state == .began {
            if let btnContent = recongnizer.view {
                btnContent.becomeFirstResponder()
                let menu = UIMenuController.shared
                menu.setTargetRect(btnContent.frame, in: btnContent.superview!)
                menu.setMenuVisible(true, animated: true)
            }
        }
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
                    if url.isFileURL {
                        self.audio?.play(voiceURL: url)
                    } else {
                        self.UUAVAudioPlayerBeiginLoadVoice()
                        FSManager.shared.fetchVoice(fromURL: url) { [weak self] in
                            if let data = $0 {
                                self?.audio?.play(songData: data)
                            } else {
                                self?.UUAVAudioPlayerFault()
                            }
                        }
                    }
                }
                self.delegate?.cellContentDidClick?(cell: self, voice: self.messageFrame.message.msgId)
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
    
    @objc fileprivate func handleDeleteMenu(_ sender: Any) {
        if let index = self.index {
            menuDelegate?.handleMenu?(cell: self, menuItem: UUMessageCell.MenuItem_Delete, at: index)
        }
    }
    
    @objc fileprivate func handleMoreMenu(_ sender: Any) {
        menuDelegate?.handleMenu?(cell: self, menuItem: UUMessageCell.MenuItem_More, at: index ?? 0)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if self.messageFrame.message.type == .voice {
            return action == #selector(handleDeleteMenu(_:)) || action == #selector(handleMoreMenu(_:)) || action == #selector(handleSpeakerMenu(_:))
        }
        return action == #selector(handleDeleteMenu(_:)) || action == #selector(handleMoreMenu(_:))
    }
    
    @objc fileprivate func handleSpeakerMenu(_ sender: UIMenuController) {
        let on = !isTurnOnSpeeker
        UIDevice.current.isProximityMonitoringEnabled = on
        if on {
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } else {
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        }
        isTurnOnSpeeker = on
        if let menuItems = sender.menuItems, menuItems.count >= 3 {
            let menuTurnOnSpeeker = menuItems[0]
            menuTurnOnSpeeker.title = speekerDescription
        }
    }
}


extension UUMessageCell {
    
    // 处理监听触发事件
    func sensorStateChange(notification: NotificationCenter) {
        if UIDevice.current.proximityState == true {
            print("切换为听筒模式")
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        } else {
            print("切换为扬声器模式")
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
    }
}


extension UUMessageCell: UUAVAudioPlayerDelegate {
    
    func UUAVAudioPlayerBeiginLoadVoice() {
        self.btnContent.benginLoadVoice()
    }
    
    func UUAVAudioPlayerBeiginPlay() {
        let on = isTurnOnSpeeker
        UIDevice.current.isProximityMonitoringEnabled = on
        if on {
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } else {
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        }
//        // 开启红外线感应
//        UIDevice.current.isProximityMonitoringEnabled = true
        self.btnContent.didLaodVoice()
    }
    
    func UUAVAudioPlayerDidFinishPlay() {
        // 关闭红外线感应
        UIDevice.current.isProximityMonitoringEnabled = false
        self.btnContent.stopPlay()
        UUAVAudioPlayer.shared.stop()
        contentVoiceIsPlaying = false
    }
    
    func UUAVAudioPlayerFault() {
        // 关闭红外线感应
        UIDevice.current.isProximityMonitoringEnabled = false
        self.btnContent.stopPlay()
        UUAVAudioPlayer.shared.stop()
        contentVoiceIsPlaying = false
    }
    
    var isTurnOnSpeeker: Bool {
        get {
            let key = "Turn On Speeker"
            guard let on = UserDefaults.standard.value(forKey: key) as? Bool else {
                UserDefaults.standard.set(true, forKey: key)
                return true
            }
            return on
        }
        set {
            let key = "Turn On Speeker"
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
    
    var speekerDescription: String {
        return !isTurnOnSpeeker ? R.string.localizable.id_turn_on_speaker() : R.string.localizable.id_turn_off_speaker()
    }
}
