//
//  SetYourWeightController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/16.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit


class SetYourWeightController: UIViewController {
    
    let changeUnit = 2.2046226218488
    
    @IBOutlet weak var weightValue: UILabel!
    @IBOutlet weak var RuleView: UIView!
    @IBOutlet weak var lbBtn: UIButton!
    @IBOutlet weak var kgBtn: UIButton!

    var weightBlock: ((Int, UnitType) -> Void)?
    
    var selectedWeight = 70
    var isUnitKg = true
    
    var ruler:TXHRrettyRuler!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self .drawRule()
        
    }
    
    
    func drawRule() -> () {
        ruler = TXHRrettyRuler(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 140))
        ruler.rulerDeletate = self
        ruler.showScrollView(withCount: 248, average: NSNumber(value: 1), currentValue: CGFloat(selectedWeight), smallMode: true)
        
        self.RuleView.insertSubview(ruler, at: 0)
    }

    
    
    
    @IBAction func backAction(_ sender: AnyObject?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func kgAction(_ sender: UIButton) {
        sender.isEnabled = false
        lbBtn.isEnabled = true
        isUnitKg = true
        
        ruler.showScrollView(withCount: 248, average: NSNumber(value: 1), currentValue: CGFloat(Double(selectedWeight)/changeUnit), smallMode: true)
    }
    
    @IBAction func lbAction(_ sender: UIButton) {
        sender.isEnabled = false
        kgBtn.isEnabled = true
        isUnitKg = false
        
        ruler.showScrollView(withCount: 550, average: NSNumber(value: 1), currentValue: CGFloat(Double(selectedWeight)*changeUnit), smallMode: true)
    }
    
    
    @IBAction func saveAction(_ sender: UIButton) {
        if self.weightBlock != nil {
            self.weightBlock!(selectedWeight, isUnitKg ? .metric : .british)
        }
        self.backAction(nil)
    }
    
}
extension SetYourWeightController: TXHRrettyRulerDelegate{
    
    func txhRrettyRuler(_ rulerScrollView: TXHRulerScrollView!) {
        selectedWeight = Int(rulerScrollView.rulerValue)
        weightValue.text = String(describing: selectedWeight)
        
    }
}
