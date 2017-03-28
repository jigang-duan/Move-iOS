//
//  UUMessageContentButton.swift
//  UUChat
//
//  Created by jiang.duan on 2017/3/2.
//  Copyright © 2017年 jiang.duan. All rights reserved.
//

import UIKit

class UUMessageContentButton: UIButton {

    // bubble image
    lazy var backImageView: UIImageView = {
        let $ = UIImageView()
        $.layer.cornerRadius = 5
        $.layer.masksToBounds = true
        $.contentMode = .scaleAspectFill
        $.isUserInteractionEnabled = false
        return $
    }()
    
    // audio
    lazy var voiceBackView: UIView = {
        let $ = UIView()
        $.backgroundColor = UIColor.clear
        $.isUserInteractionEnabled = false
        return $
    }()
    
    lazy var second: UILabel = {
        let $ = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 30))
        $.textAlignment = .center
        $.font = UIFont.systemFont(ofSize: 14)
        $.backgroundColor = UIColor.clear
        $.isUserInteractionEnabled = false
        return $
    }()
    
    lazy var voice: UIImageView = {
        let $ = UIImageView(frame: CGRect(x: 85, y: 5, width: 20, height: 20))
        $.image = UIImage(named: "chat_animation_white3")
        $.animationImages = [
            UIImage(named: "chat_animation_white1")!,
            UIImage(named: "chat_animation_white2")!,
            UIImage(named: "chat_animation_white3")!
        ]
        $.animationDuration = 1
        $.animationRepeatCount = 0
        $.isUserInteractionEnabled = false
        $.backgroundColor = UIColor.clear
        return $
    }()
    
    lazy var indicator: UIActivityIndicatorView = {
        let $ = UIActivityIndicatorView(activityIndicatorStyle: .white)
        $.center = CGPoint(x: 85, y: 15)
        $.isUserInteractionEnabled = false
        return $
    }()
    
    var isMyMessage: Bool = true {
        didSet {
            if isMyMessage {
                self.backImageView.frame = CGRect(x: 5, y: 5, width: 220, height: 220)
                self.voiceBackView.frame = CGRect(x: 15, y: 10, width: 130, height: 35)
                self.second.textColor = UIColor.white
            } else {
                self.backImageView.frame = CGRect(x: 15, y: 5, width: 220, height: 220)
                self.voiceBackView.frame = CGRect(x: 25, y: 10, width: 130, height: 35)
                self.second.textColor = UIColor.gray
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addSubViews()
    }
    
    private func addSubViews() {
        //图片
        self.addSubview(backImageView)
        
        //语音
        self.addSubview(voiceBackView)
        self.voiceBackView.addSubview(indicator)
        self.voiceBackView.addSubview(voice)
        self.voiceBackView.addSubview(second)
    }
    
    func benginLoadVoice() {
        self.voice.isHidden = true
        self.indicator.startAnimating()
    }
    
    func didLaodVoice()  {
        self.voice.isHidden = false
        self.indicator.stopAnimating()
        self.voice.startAnimating()
    }
    
    func stopPlay() {
        self.voice.stopAnimating()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(_copy(_:))
    }
    
    @objc private func _copy(_ sender: UUMessageContentButton) {
        let pboard = UIPasteboard.general
        pboard.string = self.titleLabel?.text
    }
    
}
