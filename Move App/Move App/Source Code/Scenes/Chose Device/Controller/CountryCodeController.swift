//
//  CountryCodeController.swift
//  Move App
//
//  Created by tianer on 17/3/5.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit


class CountryCodeViewController: UITableViewController {
    
    
    var cellDatas:[String] = []
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let countryCodes = Locale.isoRegionCodes
        
        var countries = [String]()
        
//        for countryCode in countryCodes {
//            let identifier = Locale.identifier(fromComponents:
//                [countryCode:NSLocale.Key.countryCode.rawValue])
//            let country = NSLocale.cu
//            countries.append(country!)
//        }
        
        cellDatas = countryCodes
        tableView.reloadData()
        
        
//        for (NSString *countryCode in countryCodes)
//        {
//            NSString *identifier = [NSLocale localeIdentifierFromComponents: [NSDictionary dictionaryWithObject: countryCode forKey: NSLocaleCountryCode]];
//            NSString *country = [[NSLocale currentLocale] displayNameForKey: NSLocaleIdentifier value: identifier];
//            [countries addObject: country];
//        }
//        
//        NSDictionary *codeForCountryDictionary = [[NSDictionary alloc] initWithObjects:countryCodes forKeys:countries];
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentify")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "cellIdentify")
        }
        
        cell?.textLabel?.text = cellDatas[indexPath.row]
        
        return cell!
    }
    
    
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDatas.count
    }
    
    
}
