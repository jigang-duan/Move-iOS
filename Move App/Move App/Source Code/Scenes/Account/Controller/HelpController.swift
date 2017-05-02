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

class HelpController: UITableViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let language = Locale.preferredLanguages.first?.components(separatedBy: "-").first ?? "en"
        
        if indexPath.row == 1 {
            open(url: URL(string: TermsConditionsURLString + language)!)
        } else if indexPath.row == 2 {
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
