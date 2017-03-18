//
//  AlertController.swift
//  Move App
//
//  Created by jiang.duan on 2017/3/8.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import Kingfisher
import AFImageHelper

class AlertController: UIViewController {
    
    struct Action {
        var title: String
        var handler: (()->Void)?
        
        init(title: String, handler: (()->Void)? = nil) {
            self.title = title
            self.handler = handler
        }
    }
    
    @IBOutlet weak var alertViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var canceBtnScaleConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconImageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var iconImage: UIImageView!
    
    var alertTitle: String?
    var iconURL: String?
    var content: String = "The content is empty"
    var cancelAction: Action?
    var confirmAction: Action?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        alertViewHeightConstraint.constant = 1.0
        //alertViewWidthConstraint.constant = 1.0
        
        titleLabel.text = alertTitle
        contentLabel.text = content
        
        okBtn.isHidden = true
        cancelBtn.isHidden = true
        confirmBtn.isHidden = true
        if let actionCancel = self.cancelAction {
            cancelBtn.setTitle(actionCancel.title, for: .normal)
            okBtn.setTitle(actionCancel.title, for: .normal)
            (self.confirmAction == nil) ? (okBtn.isHidden = false) : (cancelBtn.isHidden = false)
        }
        if let actionConfirm = self.confirmAction {
            confirmBtn.setTitle(actionConfirm.title, for: .normal)
            confirmBtn.isHidden = false
        }
        
        iconImage.isHidden = true
        iconImageHeightConstraint.constant = 0.0
        if let icon = self.iconURL, let url = URL(string: icon) {
            iconImage.isHidden = false
            iconImageHeightConstraint.constant = 48.0
            iconImage.kf.setImage(with: url,
                                  placeholder: R.image.relationship_ic_other(),
                                  options: [.transition(ImageTransition.fade(1))],
                                  progressBlock: nil,
                                  completionHandler: nil)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3) {  [unowned self] in
            let noAction = (self.cancelAction == nil) && (self.confirmAction == nil)
            self.alertViewHeightConstraint.constant = noAction ? (120.0 - 48.0) : (172.0 - 48.0)
            self.alertViewHeightConstraint.constant += self.iconImageHeightConstraint.constant
            self.alertViewWidthConstraint.constant = 240.0
            self.view.layoutIfNeeded()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backDidTap(_ sender: UITapGestureRecognizer) {
        if ((cancelAction == nil) && (confirmAction == nil)) {
            self.dismiss(animated: true)
        }
    }

    @IBAction func cancelDidTap(_ sender: UIButton) {
        self.dismiss(animated: true, completion: { [unowned self] in
            self.cancelAction?.handler?()
        })
    }
    
    @IBAction func confirmDidTap(_ sender: UIButton) {
        self.dismiss(animated: true, completion: { [unowned self] in
            self.confirmAction?.handler?()
        })
    }
    
}

