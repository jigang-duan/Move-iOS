//
//  SetYourWeightController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/16.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class SetYourWeightController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self .drawRule()
        
    }
    func drawRule() -> () {
        let rect = CGRect(x: 0, y: 0, width: RuleView.frame.size.width, height: 140)
        ruler = TXHRrettyRuler.init(frame: rect)
        ruler.rulerDeletate = self
        ruler.showScrollView(withCount: 248, average: NSNumber(value: 1), currentValue: 70, smallMode: true)
        
        self.RuleView.insertSubview(ruler, at: 0)
    }
    
    var ruler = TXHRrettyRuler()
    var currentValue : CGFloat = 50
    @IBOutlet weak var weightValue: UILabel!
    @IBOutlet weak var RuleView: UIView!
    @IBOutlet weak var lbBtn: UIButton!
    @IBOutlet weak var kgBtn: UIButton!
    
    
    
    @IBAction func BackAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func kgAction(_ sender: UIButton) {
        
        sender.isEnabled = false
        lbBtn.isEnabled = true
        
        ruler.showScrollView(withCount: 248, average: NSNumber(value: 1), currentValue: currentValue/2.3, smallMode: true)
        
        
    }
    
    @IBAction func lbAction(_ sender: UIButton) {
        sender.isEnabled = false
        kgBtn.isEnabled = true
        
        ruler.showScrollView(withCount: 550, average: NSNumber(value: 1), currentValue: currentValue*2.2, smallMode: true)
    }
    
    
    
}
extension SetYourWeightController: TXHRrettyRulerDelegate{
    
    func txhRrettyRuler(_ rulerScrollView: TXHRulerScrollView!) {
        print(rulerScrollView.rulerValue)
        currentValue = CGFloat(rulerScrollView.rulerValue)
        weightValue.text = String(describing: Int(rulerScrollView.rulerValue))
        
    }
}
