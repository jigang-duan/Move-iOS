//
//  SetYourHeghtController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/16.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit


class SetYourHeghtController: UIViewController {
    
     let changeUnit = 2.54

    var heightBlock: ((Int, UnitType) -> Void)?
    
    @IBOutlet weak var inchBun: UIButton!
    @IBOutlet weak var cmBun: UIButton!
    
    var isUnitCm = true
    
    var selectedHeight = 160
    
    var ruler:TXHRrettyRuler!
    
    @IBOutlet weak var RulesVView: UIView!
    @IBOutlet weak var heighLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self .drawRule()
        
    }
    
    func drawRule() -> () {
        ruler = TXHRrettyRuler(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 140))
        ruler.rulerDeletate = self
        ruler.showScrollView(withCount: 230, average: NSNumber(value: 1), currentValue: CGFloat(selectedHeight), smallMode: true)
        
        self.RulesVView .insertSubview(ruler, at: 0)
    }

    
    @IBAction func backAction(_ sender: AnyObject?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func inchAction(_ sender: UIButton) {
        sender.isEnabled = false
        cmBun.isEnabled = true
        isUnitCm = false
        
        ruler.showScrollView(withCount: 90, average: NSNumber(value: 1), currentValue: CGFloat(Double(selectedHeight)/changeUnit), smallMode: true)
    }
    
    @IBAction func cmAction(_ sender: UIButton) {
        sender.isEnabled = false
        inchBun.isEnabled = true
        isUnitCm = true
        
        ruler.showScrollView(withCount: 230, average: NSNumber(value: 1), currentValue: CGFloat(Double(selectedHeight)*changeUnit), smallMode: true)
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        if self.heightBlock != nil {
            self.heightBlock!(selectedHeight, isUnitCm ? .metric : .british)
        }
        self.backAction(nil)
    }
   
}
extension SetYourHeghtController: TXHRrettyRulerDelegate{

    func txhRrettyRuler(_ rulerScrollView: TXHRulerScrollView!) {
        selectedHeight = Int(rulerScrollView.rulerValue)
        heighLabel.text = String(describing: selectedHeight)
    }
}
