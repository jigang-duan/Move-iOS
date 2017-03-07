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
    
    @IBOutlet weak var SearchBarQutlet: UISearchBar!
    @IBOutlet weak var tableviewQulet: UITableView!
    
    @IBOutlet weak var delegate: SelectTimeZoneDelegate?
    
    var showTimezone: [TimeZone]!
    var showTimeZoneIdentifiers: [String]!
    var showIndexs: [[String]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showTimezone = TimeZone.knownTimeZoneIdentifiers
            .map({ TimeZone(identifier: $0) })
            .filter({ $0 != nil })
            .map({$0!})
            .filter({ ($0.abbreviation()?.contains("GMT"))! })
        
        showTimeZoneIdentifiers = showTimezone.map({$0.identifier})
        showIndexs = IndexLetter.map({ c in showTimeZoneIdentifiers.filter({ $0.substring(to: $0.index($0.startIndex, offsetBy: 1)) == c }) })
        
        SearchBarQutlet.delegate = self
        tableviewQulet.delegate = self
    }
    
}

extension SelectTimeZoneController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //如果不写东西就显示全部
        if searchText == "" {
            
        }else{
            //for循环过滤
        }
        print("s11111111")
        self.tableviewQulet.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
         searchBar.resignFirstResponder()
        print("s222222")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        //显示全部
        print("s33333")
        self.tableviewQulet.reloadData()
    }
    
}

fileprivate let IndexLetter = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters.map({String($0)})

extension SelectTimeZoneController: UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return IndexLetter.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showIndexs[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.cellTimeZone.identifier, for: indexPath)
        cell.textLabel?.text = showIndexs[indexPath.section][indexPath.row]
        cell.detailTextLabel?.text = TimeZone(identifier: showIndexs[indexPath.section][indexPath.row])?.abbreviation()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let timeZone = TimeZone(identifier: showIndexs[indexPath.section][indexPath.row]) {
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
