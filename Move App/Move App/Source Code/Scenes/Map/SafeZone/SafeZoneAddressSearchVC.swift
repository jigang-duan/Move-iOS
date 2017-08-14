//
//  SafeZoneAddressSearchVC.swift
//  Move App
//
//  Created by lx on 17/2/20.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import MapKit

protocol SearchVCdelegate : NSObjectProtocol{
    func Searchback(item : MKMapItem ) 
}

class SafeZoneAddressSearchVC: UIViewController {
    
    var delegate : SearchVCdelegate? = nil
    
    @IBOutlet weak var cancelBun: UIButton!
    @IBOutlet weak var addressTableView: UITableView!

    @IBOutlet weak var searchTextField: UITextField!
    
    let searchRequest = MKLocalSearchRequest()
    
    var searchLocation : MKLocalSearch? = nil
    
    var resultArr : NSMutableArray?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        self.title = R.string.localizable.id_search_position()
        searchTextField.placeholder = R.string.localizable.id_address_is_empty()
        cancelBun.setTitle(R.string.localizable.id_cancel(), for: .normal)
        
        searchTextField.addTarget(self, action: #selector(textDidChange), for: UIControlEvents.editingChanged)
        self.addressTableView.delegate = self
        resultArr = NSMutableArray()
    }
    
    func textDidChange() {
        searchRequest.naturalLanguageQuery = searchTextField.text
        
        searchLocation = MKLocalSearch(request: searchRequest)
        
        searchLocation?.start(completionHandler: { (response, error) in
            
            if error != nil {
                print("Error occured in search: \(error!.localizedDescription)")
            } else if response!.mapItems.count == 0 {
                print("No matches found")
            } else {
                print("Matches found")
                self.resultArr?.removeAllObjects()
                if ( response != nil && response?.mapItems != nil) {
                    for item in response!.mapItems {
                        self.resultArr?.add(item)
                    }
                    self.addressTableView.reloadData()
                }
                self.addressTableView.reloadData()
            }
        })
    }
    
    
    @IBAction func cancelClick(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
  
}
//tablview代理方法
extension SafeZoneAddressSearchVC:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (resultArr?.count)!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle , reuseIdentifier:"cell")
        }
        
        let item : MKMapItem = resultArr?.object(at: indexPath.row) as! MKMapItem
        cell?.textLabel?.text = item.placemark.name
        
        let country = item.placemark.country ?? ""
        let locality = item.placemark.locality ?? ""
        let subLocality = item.placemark.subLocality ?? ""
        let thoroughfare = item.placemark.thoroughfare ?? ""
        
        cell?.detailTextLabel?.text = country + locality + subLocality + thoroughfare
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item : MKMapItem = resultArr?.object(at: indexPath.row) as! MKMapItem
        print("\(item)")
        if (self.delegate != nil) {
            self.delegate?.Searchback(item: item)
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    

}

