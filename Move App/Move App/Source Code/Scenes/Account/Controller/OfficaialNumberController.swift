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
    
    var visibleModels: [SectionModel] = []
    var loadedModels: [SectionModel] = []
    
    var sectionIndexTitles: [String]? {
        get {
            return visibleModels.map {$0.title}
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        
        if let arr = NSArray(contentsOf: R.file.countryphonePlist()!) as? [[NSArray]] {
            loadedModels = arr.map{ SectionModel(section: $0) }
        }
        visibleModels = loadedModels
    }
    
}
extension OfficialNumberController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 0 {
            visibleModels = loadedModels.flatMap { (section) in
                SectionModel(numbers: section.officialNumbers.filter { $0.country.lowercased().contains(searchText.lowercased()) }, title: section.title)
            }
        } else {
            visibleModels = loadedModels
        }
        
        tableview.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        visibleModels = loadedModels
        tableview.reloadData()
    }
    
}


extension OfficialNumberController: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return visibleModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleModels[section].officialNumbers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.cellOfficialNumber.identifier)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: R.reuseIdentifier.cellOfficialNumber.identifier)
        }
        cell?.textLabel?.text = visibleModels[indexPath.section].officialNumbers[indexPath.row].country
        cell?.detailTextLabel?.text = visibleModels[indexPath.section].officialNumbers[indexPath.row].number
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let number = visibleModels[indexPath.section].officialNumbers[indexPath.row].number
        DefaultWireframe.sharedInstance.open(url: URL(string: "tel://\(number)")!)
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionIndexTitles?[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionIndexTitles
    }

}

struct SectionModel {
    var officialNumbers: [OfficialNumber]
    var title: String
    
    init(section: [NSArray]) {
        self.officialNumbers = section.map{ OfficialNumber(array: $0) }
        self.title = officialNumbers[0].country.characters.first.flatMap{ String($0) } ?? ""
    }
    
    init?(numbers: [OfficialNumber], title: String) {
        guard numbers.count > 0 else {
            return nil
        }
        self.officialNumbers = numbers
        self.title = title
    }
}

struct OfficialNumber {
    var country: String
    var number: String
    var abbreviation: String
    
    init(array : NSArray) {
        self.country = (array[0] as? String) ?? ""
        self.number = (array[1] as? String) ?? ""
        self.abbreviation = (array[2] as? String) ?? ""
    }
}
