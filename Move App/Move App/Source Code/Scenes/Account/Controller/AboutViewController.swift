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
        
        self.title = R.string.localizable.id_about()
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] {
            versionLab.text = "V \(version)"
        }
    }
    
    @IBAction func logDidTap(_ sender: UITapGestureRecognizer) {
        guard MFMailComposeViewController.canSendMail() else {
            print("Mail services are not available")
            return
        }
        
        let log = self.logFileURL.flatMap { try? Data(contentsOf: $0) }
        guard let logData = log else { return }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.setToRecipients(["jigang.duan@tcl.com"])
        composeVC.setSubject("Log for MT30 Family Watch iOS app!")
        composeVC.setMessageBody("Hello from California!", isHTML: false)
        composeVC.addAttachmentData(logData, mimeType: "text/plain", fileName: logFileName)
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    private var logFileURL: URL? {
        let cachePaths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        return cachePaths.first.flatMap { URL(fileURLWithPath: $0).appendingPathComponent(logFileName) }
    }
    
    private let logFileName = "swiftybeaver.log"
        
}

// MARK: delegate
extension AboutViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
}
