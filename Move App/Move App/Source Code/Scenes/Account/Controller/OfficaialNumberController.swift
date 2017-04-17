//
//  OfficaialNumberController.swift
//  Move App
//
//  Created by LX on 2017/3/15.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class OfficialNumberController: UIViewController {

    @IBOutlet var tableview: UITableView!
    
    @IBOutlet weak var search: UISearchBar!
    
    
    var visibleDatas: [Group] = []
    var cellDatas: [Group] = []
    
    var indexLetters:[String]? {
        get{
            return visibleDatas.map({$0.indexLetter})
        }
    }
    
    struct Group {
        var officialNumbers: [OfficialNumber]
        var indexLetter: String
    }
    
    struct OfficialNumber {
        var country: String
        var number: String
        var abbreviation: String
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        
        
        
        let path = Bundle.main.path(forResource: "countryphone.plist", ofType: nil)
        if let arr = NSArray(contentsOf: URL(fileURLWithPath: path ?? "")) as? [[NSArray]]{
            
            for group in arr {
                var gp = Group(officialNumbers: [], indexLetter: "")
                
                for a in group {
                    let number = OfficialNumber(country: a[0] as! String, number: a[1] as! String, abbreviation: a[2] as! String)
                    gp.officialNumbers.append(number)
                    if let letter = a[0] as? String, let c = letter.characters.first {
                        gp.indexLetter = String(c)
                    }
                }
            
                cellDatas.append(gp)
            }
        }
        visibleDatas = cellDatas
        
    }
    
}
extension OfficialNumberController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        visibleDatas = []
        
        if searchText.characters.count > 0 {
            for gp in cellDatas {
                
                var g = Group(officialNumbers: [], indexLetter: gp.indexLetter)
                for on in gp.officialNumbers {
                    if on.country.lowercased().contains(searchText.lowercased()) {
                        g.officialNumbers.append(on)
                    }
                }
                
                if g.officialNumbers.count > 0 {
                    visibleDatas.append(g)
                }
            }
        }else{
            visibleDatas = cellDatas
        }
        
        tableview.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        visibleDatas = cellDatas
        tableview.reloadData()
    }
    
}



extension OfficialNumberController: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return visibleDatas.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleDatas[section].officialNumbers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableview.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: "cell")
        }
        
        cell?.textLabel?.text = visibleDatas[indexPath.section].officialNumbers[indexPath.row].country
        cell?.detailTextLabel?.text = visibleDatas[indexPath.section].officialNumbers[indexPath.row].number
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let number = visibleDatas[indexPath.section].officialNumbers[indexPath.row].number
        if let url = URL(string: "tel://\(number)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return indexLetters?[section]
    }
    
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indexLetters
    }

}

