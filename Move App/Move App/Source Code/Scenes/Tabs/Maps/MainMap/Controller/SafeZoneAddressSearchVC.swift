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

class SafeZoneAddressSearchVC: UIViewController , UITableViewDelegate , UITableViewDataSource{
    
    var delegate : SearchVCdelegate? = nil
    
    @IBOutlet weak var addressTableView: UITableView!

    @IBOutlet weak var searchTextField: UITextField!
    
    let searchRequest = MKLocalSearchRequest()
    
    var searchLocation : MKLocalSearch? = nil
    
    var resultArr : NSMutableArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.addTarget(self, action: #selector(textDidChange), for: UIControlEvents.editingChanged)
        self.addressTableView.delegate = self
        resultArr = NSMutableArray()
        // Do any additional setup after loading the view.
    }

    func performSearch() {
        
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
                for item in response!.mapItems {
                    print("Name = \(item.name)")
                    print("Phone = \(item.phoneNumber)")
                    self.resultArr?.add(item)
                }
                self.addressTableView.reloadData()
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textDidChange() {
        self.performSearch()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (resultArr?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle , reuseIdentifier:"cell")
        }
        let item : MKMapItem = resultArr?.object(at: indexPath.row) as! MKMapItem
        cell?.textLabel?.text = item.name
        let str = String.init(format: "%@%@", item.placemark.country! ,item.placemark.locality!)
        cell?.detailTextLabel?.text = str
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item : MKMapItem = resultArr?.object(at: indexPath.row) as! MKMapItem
        print("\(item)")
        if (self.delegate != nil) {
            self.delegate?.Searchback(item: item)
        }
    }
}

