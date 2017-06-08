//
//  CountryCodeController.swift
//  Move App
//
//  Created by tianer on 17/3/5.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import CoreTelephony


class CountryCodeViewController: UITableViewController {
    
    @IBOutlet weak var nextBun: UIBarButtonItem!
    
    var selectBlock: ((CountryCode) -> ())?
    
    
    fileprivate var cellDatas:[sectionModel] = []
    
    fileprivate struct sectionModel {
        var models: [CountryCode]?
        var title: String?
    }
    
    struct CountryCode {
        var name: String?
        var abbr: String?
        var code: String?
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        let path = Bundle.main.path(forResource: "countryCode", ofType: "plist")
        let arr = NSArray(contentsOfFile: path!) as! [[String:String]]
    
        
        let sArr = arr.map({dic -> (model: CountryCodeViewController.CountryCode, title: String) in
            let cd = CountryCode(name: dic["countryName"], abbr: dic["abbreviation"], code: dic["code"])
            let title = String((cd.name?.characters.first)!)
            return (model: cd, title: title)
        })
        let titleArr = Array(Set(sArr.map({$0.title}))).sorted()
        
        for i in 0..<titleArr.count {
            var models: [CountryCode] = []
            for j in 0..<sArr.count {
                let m = sArr[j]
                if m.title == titleArr[i] {
                    models.append(CountryCode(name: m.model.name, abbr: m.model.abbr, code: m.model.code))
                }
            }
            
            let sm = sectionModel(models: models, title: titleArr[i])
            cellDatas.append(sm)
        }
    
        let noneModel = CountryCode(name: "None", abbr: "-", code: "-")
        
        if let localModel = CountryCodeViewController.localCountryCode() {
            let first = sectionModel(models: [noneModel,localModel], title: "Location")
            cellDatas.insert(first, at: 0)
        }else{
            let first = sectionModel(models: [noneModel], title: "Location")
            cellDatas.insert(first, at: 0)
        }
        
    
        self.tableView.reloadData()
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentify")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "cellIdentify")
        }
        
        cell?.textLabel?.text = cellDatas[indexPath.section].models?[indexPath.row].name
        cell?.detailTextLabel?.text = cellDatas[indexPath.section].models?[indexPath.row].code
        
        return cell!
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = cellDatas[indexPath.section].models?[indexPath.row]
        if selectBlock != nil {
            selectBlock!(model!)
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return cellDatas.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDatas[section].models!.count
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return cellDatas[section].title
    }
    
    
    
}


extension CountryCodeViewController {
    
    class func localCountryCode() -> CountryCode? {
        let info = CTTelephonyNetworkInfo()
        if let carrier = info.subscriberCellularProvider {
            let path = Bundle.main.path(forResource: "countryCode", ofType: "plist")
            let arr = NSArray(contentsOfFile: path!) as! [[String:String]]
            let ccs = arr.map({CountryCode(name: $0["countryName"], abbr: $0["abbreviation"], code: $0["code"])})
                        .filter { $0.abbr?.lowercased() == carrier.isoCountryCode?.lowercased()}
            
            if ccs.count > 0 {
                return ccs[0]
            }else{
                return nil
            }
        }else{
            return nil
        }
    }
    
    class func fetchCountryCode(with code: String) -> CountryCode? {
        let path = Bundle.main.path(forResource: "countryCode", ofType: "plist")
        let arr = NSArray(contentsOfFile: path!) as! [[String:String]]
        let ccs = arr.map({CountryCode(name: $0["countryName"], abbr: $0["abbreviation"], code: $0["code"])})
            .filter { $0.code?.lowercased() == code.lowercased()}
        if ccs.count > 0 {
            return ccs[0]
        }else{
            return nil
        }
    }
    
}





