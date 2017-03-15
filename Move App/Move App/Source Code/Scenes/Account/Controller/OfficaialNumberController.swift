//
//  OfficaialNumberController.swift
//  Move App
//
//  Created by LX on 2017/3/15.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class OfficaialNumberController: UIViewController {

    @IBOutlet var tableview: UITableView!
    
    var allArray :[NSDictionary]?
    
    fileprivate var IndexLetter = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters.map({String($0)})
    
    var searchController: UISearchController?
    var cityNameArray: [String]!
    var visibleResultsIndexs: [[String]]!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
//        tableview.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
        
        
        searchController = UISearchController(searchResultsController: nil)
        self.searchController?.searchResultsUpdater = self
        self.searchController?.dimsBackgroundDuringPresentation = false
        self.searchController?.delegate = self
        self.searchController?.searchBar .sizeToFit()
        self.definesPresentationContext = true
        
        tableview.tableHeaderView = self.searchController?.searchBar
//        let path = Bundle.main.path(forResource: "officaialNumber.plist", ofType: nil)
//        let data = NSMutableDictionary(contentsOfFile: path!)
//        self.allArray = data?["cityOrnumber"] as! [NSDictionary]?
//        
//        for i in 0 ..< (self.allArray?.count)!
//        {
//            cityNameArray?.append(self.allArray?[i]["cityName"] as! String)
//            
//        }
//        visibleResultsIndexs = IndexLetter.map({ c in cityNameArray.filter({ $0.substring(to: $0.index($0.startIndex, offsetBy: 1)) == c }) })
        
    }
    
}
extension OfficaialNumberController: UISearchResultsUpdating,UISearchControllerDelegate {
    
    //点取消搜索
    func willDismissSearchController(_ searchController: UISearchController) {
        self.tableview.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        
//        visibleResultsIndexs = IndexLetter.map({ c in visibleResultsIdentifiers.filter({ $0.substring(to: $0.index($0.startIndex, offsetBy: 1)) == c }) })
//        self.tableviewQulet.reloadData()
    }
    
    //更新
    func updateSearchResults(for searchController: UISearchController) {
//        if let text = searchController.searchBar.text,
//            let count = searchController.searchBar.text?.characters.count, count > 0 {
//            visibleResultsIdentifiers = ableTimeZoneIdentifiers.filter({ $0.contains(text) })
//        } else {
//            visibleResultsIdentifiers = ableTimeZoneIdentifiers
//        }
//        visibleResultsIndexs = IndexLetter.map({ c in visibleResultsIdentifiers.filter({ $0.substring(to: $0.index($0.startIndex, offsetBy: 1)) == c }) })
//        self.tableviewQulet.reloadData()
    }
    
    
}


extension OfficaialNumberController: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.IndexLetter.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.visibleResultsIndexs[section].count
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: R.reuseIdentifier.officialnumaberCell.identifier, for: indexPath)
        let cellNumber = cell.accessoryView as! UILabel
        
//        cell.textLabel?.text = visibleResultsIndexs[indexPath.section][indexPath.row]
//        
//        for i in 0 ..< (self.allArray?.count)!
//        {
//           if cell.textLabel?.text == self.allArray?[i]["cityName"] as? String
//           {
//                cellNumber.text = self.allArray?[i]["Number"] as! String
//            }
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //电话功能 ：模拟器没有电话功能
        let url = NSURL(string: "tel://10086")
        UIApplication.shared.openURL(url! as URL)
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return IndexLetter[section]
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return IndexLetter
    }

}
