//
//  MapDeviceListView.swift
//  Move App
//
//  Created by lx on 17/3/8.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class MapDeviceListView: UIView {

    @IBOutlet weak var tableView: UITableView!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let nib = UINib(nibName: "MapDeviceCell", bundle: nil) //nibName指的是我们创建的Cell文件名
        tableView.register(nib, forCellReuseIdentifier: "MapDeviceCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension MapDeviceListView : UITableViewDelegate ,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "MapDeviceCell", for: indexPath) as! MapDeviceCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
