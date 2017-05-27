//
//  AboutViewController.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/4/19.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import MessageUI

class AboutViewController: UIViewController {
    
    @IBOutlet weak var versionLab: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] {
            versionLab.text = "V \(version)"
        }
    }
    
    @IBAction func logDidTap(_ sender: UITapGestureRecognizer) {
        guard MFMailComposeViewController.canSendMail() else {
            print("Mail services are not available")
            return
        }
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.setToRecipients(["jigang.duan@tcl.com"])
        composeVC.setSubject("Hello!")
        composeVC.setMessageBody("Hello from California!", isHTML: false)
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
}

// MARK: delegate
extension AboutViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
}
