//
//  HelpController.swift
//  Move App
//
//  Created by jiang.duan on 2017/5/2.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import SafariServices

fileprivate let TermsConditionsURLString = "http://www.tcl-move.com/help/#/mt30_terms_and_conditions/"
fileprivate let PrivacyPolicyURLString = "http://www.tcl-move.com/help/#/mt30_privacy_policy/"
fileprivate let UserManualURLString = "http://www.tcl-move.com/help/url.html#/mt30/um/generic/"
fileprivate let FaqURLString = "http://www.tcl-move.com/help/#/mt30/faqs/"

class HelpController: UITableViewController {

    @IBOutlet weak var cellLab1: UILabel!
    @IBOutlet weak var cellLab2: UILabel!
    @IBOutlet weak var cellLab3: UILabel!
    @IBOutlet weak var cellLab4: UILabel!
    
    private func initializeI18N() {
        self.title = R.string.localizable.id_help()
        
        cellLab1.text = R.string.localizable.id_help_faq()
        cellLab2.text = R.string.localizable.id_user_manual()
        cellLab3.text = R.string.localizable.id_terms_of_use_help()
        cellLab4.text = R.string.localizable.id_privacy_and_security()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeI18N()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let language = Bundle.main.preferredLocalizations[0].components(separatedBy: "-").first ?? "en"
        
        if indexPath.row == 0 {
            open(url: URL(string: FaqURLString + language)!)
        } else if indexPath.row == 1 {
            open(url: URL(string: UserManualURLString + language)!)
        } else if indexPath.row == 2 {
            open(url: URL(string: TermsConditionsURLString + language)!)
        }else if indexPath.row == 3{
            open(url: URL(string: PrivacyPolicyURLString + language)!)
        }
    }
    
    private func open(url: URL) {
        if #available(iOS 9.0, *) {
            let sVC = SFSafariViewController(url: url)
            self.present(sVC, animated: true, completion: nil)
        } else {
            let webVC = WebViewController()
            webVC.targetURL = url
            self.navigationController?.show(webVC, sender: nil)
        }
    }

}


class WebViewController: UIViewController {
    
    var targetURL: URL?
    let webView: UIWebView = UIWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.frame = view.bounds
        self.webView.scalesPageToFit = true
        self.webView.delegate = self
        self.view.addSubview(self.webView)
        loadAddressURL()
    }
    
    
    func loadAddressURL() {
        guard let url = targetURL else {
            return
        }
        let req = URLRequest(url: url)
        self.webView.loadRequest(req)
    }
}

// MARK: delegate
extension WebViewController: UIWebViewDelegate {
    
}
