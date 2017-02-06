//
//  DistributionViewController.swift
//  Move App
//
//  Created by Jiang Duan on 17/1/19.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class DistributionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func unwindSegueToDistribution(segue: UIStoryboardSegue) {
        if let typeInfoChoseDevice = R.segue.choseDeviceController.unwindChoseDevice(segue: segue) {
            Logger.debug(typeInfoChoseDevice)
        }
        
    }

}

