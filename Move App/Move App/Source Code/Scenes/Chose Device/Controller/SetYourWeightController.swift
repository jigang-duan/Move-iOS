//
//  SetYourWeightController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/16.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import CustomViews


class SetYourWeightController: UIViewController {
    
    let changeUnit = 2.2046226218488
    let maxKg: UInt = 248
    let maxLb: UInt = 550
    
    @IBOutlet weak var weightLab: UILabel!
    @IBOutlet weak var rulerView: UIView!
    @IBOutlet weak var lbBtn: UIButton!
    @IBOutlet weak var kgBtn: UIButton!

    var weightBlock: ((Int, UnitType) -> Void)?
    
    var selectedWeight = 70
    var isUnitKg = true
    
    var ruler:CustomRuler!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self .drawRule()
        
        kgBtn.isEnabled = !isUnitKg
        lbBtn.isEnabled = isUnitKg
        self.weightLab.text = "\(selectedWeight)"
    }
    
    
    func drawRule() -> () {
        ruler = CustomRuler(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 140))
        ruler.showRuler(with: isUnitKg ? maxKg:maxLb, currentValue: UInt(selectedWeight))
        ruler.selectValue = { value in
            self.selectedWeight = Int(value)
            self.weightLab.text = "\(value)"
        }
        self.rulerView.insertSubview(ruler, at: 0)
    }

    
    @IBAction func backAction(_ sender: AnyObject?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func kgAction(_ sender: UIButton) {
        sender.isEnabled = false
        lbBtn.isEnabled = true
        isUnitKg = true
        
        let currentValue = UInt(Double(selectedWeight)/changeUnit)
        ruler.showRuler(with: maxKg, currentValue: currentValue > maxKg ? maxKg:currentValue)
    }
    
    @IBAction func lbAction(_ sender: UIButton) {
        sender.isEnabled = false
        kgBtn.isEnabled = true
        isUnitKg = false
        
        let currentValue = UInt(Double(selectedWeight)*changeUnit)
        ruler.showRuler(with: maxLb, currentValue: currentValue > maxLb ? maxLb:currentValue)
    }
    
    
    @IBAction func saveAction(_ sender: UIButton) {
        if self.weightBlock != nil {
            self.weightBlock!(selectedWeight, isUnitKg ? .metric : .british)
        }
        self.backAction(nil)
    }
    
}

