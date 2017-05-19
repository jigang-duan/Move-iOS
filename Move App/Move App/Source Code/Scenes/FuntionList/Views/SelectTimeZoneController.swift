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
    
    
    @IBOutlet weak var selecttimezoneTitleItem: UINavigationItem!
    
    
    @IBOutlet weak var tableview: UITableView!
    
    var searchController: UISearchController?
    
    
    var visibleResults: [[TimezoneInfo]] = []
    
    var ableTimezones: [[TimezoneInfo]] = []
    
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        
        searchController = UISearchController(searchResultsController: nil)
        self.searchController?.searchResultsUpdater = self
        self.searchController?.dimsBackgroundDuringPresentation = false
        self.searchController?.delegate = self
        self.searchController?.searchBar .sizeToFit()
        self.tableview.tableHeaderView = self.searchController?.searchBar
        self.definesPresentationContext = true
        
        
        DeviceManager.shared.fetchTimezones()
            .subscribe(onNext: {[weak self] tms in
                
                let letters = tms
                    .map({$0.timezoneId!.components(separatedBy: "/").first!})
                let results = Array(Set(letters))
                
                for i in 0..<results.count {
                    var tempTms:[TimezoneInfo] = []
                    for tm in tms {
                        if results[i] == tm.timezoneId?.components(separatedBy: "/").first {
                            tempTms.append(tm)
                        }
                    }
                    self?.ableTimezones.append(tempTms)
                }
                self?.visibleResults = (self?.ableTimezones)!
                self?.tableview.reloadData()
            })
            .addDisposableTo(disposeBag)
        
    }
}


extension SelectTimeZoneController: UISearchResultsUpdating,UISearchControllerDelegate {
    
    func willDismissSearchController(_ searchController: UISearchController) {
        visibleResults = ableTimezones
        self.tableview.reloadData()
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text,text.characters.count > 0 {
            visibleResults = []
            for tms in ableTimezones {
                let t = tms.filter({ $0.timezoneId?.lowercased().contains(text.lowercased()) == true })
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
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.cellTimeZone.identifier, for: indexPath)
        
        let tm = visibleResults[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = tm.timezoneId
        if let offset = tm.gmtoffset {
            if offset > 0 {
                cell.detailTextLabel?.text = "\(tm.countryname ?? "")  GMT +\(offset)"
            }else if offset == 0{
                cell.detailTextLabel?.text = "\(tm.countryname ?? "")  GMT"
            }else{
                cell.detailTextLabel?.text = "\(tm.countryname ?? "")  GMT \(offset)"
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selectedTimezone != nil {
            let tm = visibleResults[indexPath.section][indexPath.row]
            self.selectedTimezone!(tm.timezoneId!)
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        let strs = visibleResults.map({$0[0].timezoneId!.components(separatedBy: "/").first!})
        return strs.map{$0.substring(to: ($0.index($0.startIndex, offsetBy: 2)))}
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return visibleResults[section][0].timezoneId?.components(separatedBy: "/").first
    }
    
}







