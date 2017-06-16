//
//  SetYourHeghtController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/16.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import CustomViews


class SetYourHeghtController: UIViewController {
    
    let changeUnit = 2.54
    let maxInch: UInt = 90
    let maxCm: UInt = 230

    var heightBlock: ((Int, UnitType) -> Void)?
    
    @IBOutlet weak var inchBun: UIButton!
    @IBOutlet weak var cmBun: UIButton!
    
    var isUnitCm = true
    var selectedHeight = 160
    
    var ruler:CustomRuler!
    
    @IBOutlet weak var rulerView: UIView!
    @IBOutlet weak var heightLab: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self .drawRule()
        
        inchBun.isEnabled = isUnitCm
        cmBun.isEnabled = !isUnitCm
        self.heightLab.text = "\(selectedHeight)"
    }
    
    func drawRule() -> () {
        ruler = CustomRuler(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
        ruler.showRuler(with: isUnitCm ? maxCm:maxInch, currentValue: UInt(selectedHeight))
        ruler.selectValue = { value in
            self.selectedHeight = Int(value)
            self.heightLab.text = "\(value)"
        }
        self.rulerView.insertSubview(ruler, at: 0)
    }

    
    @IBAction func backAction(_ sender: AnyObject?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func inchAction(_ sender: UIButton) {
        sender.isEnabled = false
        cmBun.isEnabled = true
        isUnitCm = false
        
        let currentValue = UInt(Double(selectedHeight)/changeUnit)
        ruler.showRuler(with: maxInch, currentValue: currentValue > maxInch ? maxInch:currentValue)
    }
    
    @IBAction func cmAction(_ sender: UIButton) {
        sender.isEnabled = false
        inchBun.isEnabled = true
        isUnitCm = true
        
        let currentValue = UInt(Double(selectedHeight)*changeUnit)
        ruler.showRuler(with: maxCm, currentValue: currentValue > maxCm ? maxCm:currentValue)
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        if self.heightBlock != nil {
            self.heightBlock!(selectedHeight, isUnitCm ? .metric : .british)
        }
        self.backAction(nil)
    }
   
}

