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

@objc
protocol SelectTimeZoneDelegate {
    @objc optional func selectedTimeZone(_ timeZone: TimeZone)
}

class SelectTimeZoneController: UIViewController {
    
    @IBOutlet weak var tableviewQulet: UITableView!
    @IBOutlet weak var delegate: SelectTimeZoneDelegate?
    
    var searchController: UISearchController?
    var visibleResultsIdentifiers: [String]!
    var visibleResultsIndexs: [[String]]!
    
    fileprivate var IndexLetter = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters.map({String($0)})
    
    var ableTimeZoneIdentifiers: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let showTimezone = TimeZone.knownTimeZoneIdentifiers
            .map({ TimeZone(identifier: $0) })
            .filter({ $0 != nil })
            .map({$0!})
            //.filter({ ($0.abbreviation()?.contains("GMT"))! })
        
        ableTimeZoneIdentifiers = showTimezone.map({$0.identifier})
        visibleResultsIdentifiers = ableTimeZoneIdentifiers
        visibleResultsIndexs = IndexLetter.map({ c in visibleResultsIdentifiers.filter({ $0.substring(to: $0.index($0.startIndex, offsetBy: 1)) == c }) })
        
        tableviewQulet.delegate = self
        
        searchController = UISearchController(searchResultsController: nil)
        self.searchController?.searchResultsUpdater = self
        self.searchController?.dimsBackgroundDuringPresentation = false
        self.searchController?.delegate = self
        self.searchController?.searchBar .sizeToFit()
        self.tableviewQulet.tableHeaderView = self.searchController?.searchBar
        self.definesPresentationContext = true
        
    }
}


extension SelectTimeZoneController: UISearchResultsUpdating,UISearchControllerDelegate {
    
    func willDismissSearchController(_ searchController: UISearchController) {
        visibleResultsIdentifiers = ableTimeZoneIdentifiers
        visibleResultsIndexs = IndexLetter.map({ c in visibleResultsIdentifiers.filter({ $0.substring(to: $0.index($0.startIndex, offsetBy: 1)) == c }) })
        self.tableviewQulet.reloadData()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text,
            let count = searchController.searchBar.text?.characters.count, count > 0 {
            visibleResultsIdentifiers = ableTimeZoneIdentifiers.filter({ $0.contains(text) })
        } else {
            visibleResultsIdentifiers = ableTimeZoneIdentifiers
        }
        visibleResultsIndexs = IndexLetter.map({ c in visibleResultsIdentifiers.filter({ $0.substring(to: $0.index($0.startIndex, offsetBy: 1)) == c }) })
        self.tableviewQulet.reloadData()
    }
    
    
}


extension SelectTimeZoneController: UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return IndexLetter.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.visibleResultsIndexs[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.cellTimeZone.identifier, for: indexPath)
        cell.textLabel?.text = visibleResultsIndexs[indexPath.section][indexPath.row]
        cell.detailTextLabel?.text = TimeZone(identifier: visibleResultsIndexs[indexPath.section][indexPath.row])?.abbreviation()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let timeZone = TimeZone(identifier: visibleResultsIndexs[indexPath.section][indexPath.row]) {
            self.delegate?.selectedTimeZone?(timeZone)
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return IndexLetter
    }
}



//--------------------------------------------------------------------------
extension Reactive where Base: SelectTimeZoneController {
    
    /// Reactive wrapper for `delegate`.
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    var delegate: DelegateProxy {
        return RxSelectTimeZoneDelegateProxy.proxyForObject(base)
    }
    
    var selected: ControlEvent<TimeZone> {
        let source = delegate
            .methodInvoked(#selector(SelectTimeZoneDelegate.selectedTimeZone(_:)))
            .map {
                return try castOrThrow(TimeZone.self, $0[0])
        }
        return ControlEvent(events: source)
    }
}

class RxSelectTimeZoneDelegateProxy
        : DelegateProxy
        , DelegateProxyType
    , SelectTimeZoneDelegate {
        
        /// For more information take a look at `DelegateProxyType`.
        class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
            let vc: SelectTimeZoneController = castOrFatalError(object)
            vc.delegate = castOptionalOrFatalError(delegate)
        }
        
        /// For more information take a look at `DelegateProxyType`.
        class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
            let vc: SelectTimeZoneController = castOrFatalError(object)
            return vc.delegate
        }
}

fileprivate func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    return returnValue
}
