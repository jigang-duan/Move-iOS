//
//  AlertController.swift
//  Move App
//
//  Created by jiang.duan on 2017/3/8.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import Kingfisher


fileprivate let AlertView_Size = CGSize(width: 240.0, height: 164.0)

fileprivate let Main_Screen_Height = UIScreen.main.bounds.size.height
fileprivate let Main_Screen_Width = UIScreen.main.bounds.size.width

fileprivate let AlertView_noImage_Size = CGSize(width: 240.0, height: 124.0)
fileprivate let AlertView_BeginSize = CGSize(width: 240.0, height: 1.0)
fileprivate let Btn_Size = CGSize(width: 120.0, height: 32.0)

class NoticeAlertControoler {
    
    struct Action {
        var title: String
        var handler: (()->Void)?
        
        init(title: String, handler: (()->Void)? = nil) {
            self.title = title
            self.handler = handler
        }
    }
    
    var alertTitle: String?
    var iconURL: String?
    var content: String = "The content is emptyd"
    var cancelAction = Action(title: R.string.localizable.id_cancel())
    var confirmAction: Action?
    
    lazy var backgroundViwe: UIView = {
        let $ = UIView(frame: CGRect(x: 0, y: 0,
                                     width: Main_Screen_Width,
                                     height: Main_Screen_Height))
        $.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        return $
    }()
    
    lazy var alertView: UIView = {
        let $ = UIView()
        $.frame.size = AlertView_Size
        $.backgroundColor = R.color.appColor.icons()
        $.borderColor = UIColor.clear
        $.cornerRadius = 3.0
        $.borderWidth = 1
        return $
    }()
    
    lazy var titleLabel: UILabel = {
        let $ = UILabel()
        $.text = "Waring"
        $.font = UIFont.systemFont(ofSize: 16.0)
        $.textColor = R.color.appColor.secondayText()
        $.textAlignment = .center
        $.frame = CGRect(x: 10, y: 8, width: AlertView_Size.width - 20, height: 20.0)
        
        return $
    }()
    
    lazy var contentLabel: UILabel = {
        let $ = UILabel()
        $.text = "The content is empty"
        $.font = UIFont.systemFont(ofSize: 15.0)
        $.textColor = UIColor.black.withAlphaComponent(0.6)
        $.numberOfLines = 2
        $.textAlignment = .center
        let y = AlertView_Size.height - Btn_Size.height - 48.0
        $.frame = CGRect(x: 10,
                         y: y,
                         width: AlertView_Size.width - 20,
                         height: 40.0)
        return $
    }()
    
    lazy var cancelBtn: UIButton = {
        let $ = UIButton(type: .custom)
        $.setTitle("Cancel", for: .normal)
        $.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        $.setTitleColor(R.color.appColor.primary(), for: .normal)
        $.setTitleColor(R.color.appColor.primary().withAlphaComponent(0.5), for: .highlighted)
        $.isHidden = true
        $.frame = CGRect(x: 0.0,
                         y: AlertView_Size.height - Btn_Size.height,
                         width: Btn_Size.width,
                         height: Btn_Size.height)
        $.borderColor = R.color.appColor.background()
        $.cornerRadius = 3.0
        $.borderWidth = 1
        return $
    }()
    
    lazy var confirmBtn: UIButton = {
        let $ = UIButton(type: .custom)
        $.setTitle("Confirm", for: .normal)
        $.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        $.setTitleColor(R.color.appColor.primary(), for: .normal)
        $.setTitleColor(R.color.appColor.primary().withAlphaComponent(0.5), for: .highlighted)
        $.isHidden = true
        $.frame = CGRect(x: Btn_Size.width,
                         y: AlertView_Size.height - Btn_Size.height,
                         width: Btn_Size.width,
                         height: Btn_Size.height)
        $.borderColor = R.color.appColor.background()
        $.cornerRadius = 3.0
        $.borderWidth = 1
        return $
    }()
    
    
    lazy var iconImage: UIImageView = {
        let $ = UIImageView()
        $.frame = CGRect(x: AlertView_Size.width/2 - 20, y: 34, width: 42.0, height: 42.0)
        $.backgroundColor = UIColor.gray
        $.layer.masksToBounds = true
        $.layer.cornerRadius = 42.0 / 2
        return $
    }()
    
    func show() {
        alertView.addSubview(titleLabel)
        
        alertView.addSubview(cancelBtn)
        alertView.addSubview(confirmBtn)
        
        alertView.addSubview(contentLabel)
        alertView.addSubview(iconImage)
        
        alertView.center.x = backgroundViwe.center.x
        alertView.center.y = backgroundViwe.center.y - 40
        backgroundViwe.addSubview(alertView)
        
        let window = UIApplication.shared.keyWindow
        window?.addSubview(backgroundViwe)
        
        titleLabel.text = alertTitle
        contentLabel.text = content
        contentLabel.adjustsFontSizeToFitWidth = true
        
        confirmBtn.addTarget(self, action: #selector(confirmDidTap(_:)), for: .touchUpInside)
        cancelBtn.addTarget(self, action: #selector(cancelDidTap(_:)), for: .touchUpInside)
        
        if let icon = self.iconURL, let url = URL(string: icon) {
            iconImage.kf.setImage(with: url,
                                  placeholder: R.image.relationship_ic_other(),
                                  options: [.transition(ImageTransition.fade(1))],
                                  progressBlock: nil,
                                  completionHandler: nil)
        }
        
        alertView.frame.size = AlertView_BeginSize
        UIView.animate(withDuration: 0.6, animations: {
            self.alertView.frame.size = AlertView_Size
        }) { _ in
            
            self.cancelBtn.setTitle(self.cancelAction.title, for: .normal)
            self.cancelBtn.isHidden = false
            
            if let actionConfirm = self.confirmAction {
                self.confirmBtn.setTitle(actionConfirm.title, for: .normal)
                self.confirmBtn.isHidden = false
            } else {
                self.cancelBtn.frame.size.width = AlertView_Size.width
            }
        }
        
    }
    
    @objc func cancelDidTap(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            self?.alertView.alpha = 0.0
            }, completion: { [weak self] _ in
                self?.cancelAction.handler?()
                self?.dismiss()
        })
    }
    
    @objc func confirmDidTap(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            self?.alertView.alpha = 0.0
            }, completion: { [weak self] _ in
                self?.confirmAction?.handler?()
                self?.dismiss()
        })
    }
    
    func dismiss() {
        self.backgroundViwe.removeFromSuperview()
    }
    
}
