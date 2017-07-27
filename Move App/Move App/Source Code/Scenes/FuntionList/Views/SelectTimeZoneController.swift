//
//  SelectTimeZoneController.swift
//  Move App
//
//  Created by LX on 2017/3/7.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional


class SelectTimeZoneController: UIViewController {
    
    var selectedTimezone: ((String) -> ())?
    
    @IBOutlet weak var tableview: UITableView!
    
    var visibleResults: [[TimeZone]] = []
    var ableTimezones: [[TimeZone]] = []
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = R.string.localizable.id_select_time_zone()
        
        tableview.delegate = self
        
        
        
        let allTimezones = TimeZone.knownTimeZoneIdentifiers.map { identifier in
            TimeZone(identifier: identifier)!
        }
        
        let letters = allTimezones
            .map({$0.identifier.components(separatedBy: "/").first!})
        let results = Array(Set(letters))

        for i in 0..<results.count {
            var tempTms:[TimeZone] = []
            for tm in allTimezones {
                if results[i] == tm.identifier.components(separatedBy: "/").first {
                    tempTms.append(tm)
                }
            }
            ableTimezones.append(tempTms)
        }
        
        visibleResults = ableTimezones
        
        tableview.reloadData()
        
//        DeviceManager.shared.fetchTimezones()
//            .subscribe(onNext: {[weak self] res in
//                //地区去重
//                var tms = [TimezoneInfo]()
//                res.forEach({ tm in
//                    if !tms.contains(where: { $0.timezoneId == tm.timezoneId}) {
//                        tms.append(tm)
//                    }
//                })
//                
//                let letters = tms
//                    .map({$0.timezoneId!.components(separatedBy: "/").first!})
//                let results = Array(Set(letters))
//                
//                for i in 0..<results.count {
//                    var tempTms:[TimezoneInfo] = []
//                    for tm in tms {
//                        if results[i] == tm.timezoneId?.components(separatedBy: "/").first {
//                            tempTms.append(tm)
//                        }
//                    }
//                    self?.ableTimezones.append(tempTms)
//                }
//                self?.visibleResults = (self?.ableTimezones)!
//                self?.tableview.reloadData()
//            })
//            .addDisposableTo(disposeBag)
        
    }
}


extension SelectTimeZoneController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)  {
        visibleResults = ableTimezones
        self.tableview.reloadData()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 0 {
            visibleResults = []
//            for tm in ableTimezones {
//                if tm.identifier.lowercased().contains(searchText.lowercased()) || (tm.localizedName(for: .generic, locale: Locale.current)!.lowercased().contains(searchText.lowercased())){
//                    visibleResults.append(tm)
//                }
//            }
            for tms in ableTimezones {
                let t = tms.filter({ $0.identifier.lowercased().contains(searchText.lowercased()) == true })
                if t.count > 0 {
                    visibleResults.append(t)
                }
            }
        } else {
            visibleResults = ableTimezones
        }
        self.tableview.reloadData()
    }
    
    
}


extension SelectTimeZoneController: UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return visibleResults.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.visibleResults[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.cellTimeZone.identifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: R.reuseIdentifier.cellTimeZone.identifier)
        }
        
        let tm = visibleResults[indexPath.section][indexPath.row]
        
        cell?.textLabel?.text = tm.identifier
        cell?.detailTextLabel?.text = tm.localizedName(for: .generic, locale: Locale.current)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selectedTimezone != nil {
            let tm = visibleResults[indexPath.section][indexPath.row]
            self.selectedTimezone!(tm.identifier)
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        let strs = visibleResults.map({$0[0].identifier.components(separatedBy: "/").first!})
        return strs.map{$0.substring(to: ($0.index($0.startIndex, offsetBy: 2)))}
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return visibleResults[section][0].identifier.components(separatedBy: "/").first
    }
    
}







