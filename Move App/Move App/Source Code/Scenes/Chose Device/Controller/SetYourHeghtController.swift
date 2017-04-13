//
//  SetYourHeghtController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/16.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit


class SetYourHeghtController: UIViewController {

    var heightBlock: ((Int) -> Void)?
    
    var selectedHeight = 160
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self .drawRule()
        
    }
    func drawRule() -> () {
        let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 140)
        let ruler = TXHRrettyRuler.init(frame: rect)
        ruler.rulerDeletate = self
        ruler.showScrollView(withCount: 230, average: NSNumber(value: 1), currentValue: CGFloat(selectedHeight), smallMode: true)
        
        self.RulesVView .insertSubview(ruler, at: 0)
    }
    
    @IBOutlet weak var RulesVView: UIView!
    @IBOutlet weak var heighLabel: UILabel!

    
    
    
    
    @IBAction func BackAction(_ sender: AnyObject?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func saveAction(_ sender: UIButton) {
        if self.heightBlock != nil {
            self.heightBlock!(selectedHeight)
        }
        self.BackAction(nil)
    }
   
}
extension SetYourHeghtController: TXHRrettyRulerDelegate{

    func txhRrettyRuler(_ rulerScrollView: TXHRulerScrollView!) {
        print(rulerScrollView.rulerValue)
        selectedHeight = Int(rulerScrollView.rulerValue)
        heighLabel.text = String(describing: selectedHeight)
    }
}
