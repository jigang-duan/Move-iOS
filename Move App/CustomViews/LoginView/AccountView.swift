//
//  AccountView.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/9.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit


@IBDesignable
public class AccountView: UIView {
    var accounterror = false
    
    override public init(frame: CGRect){
            super.init(frame: frame)
            initialFromXib()
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialFromXib()
    }
    

    @IBOutlet var contenView: UIView!
    @IBOutlet weak var accountErrorLabel: UILabel!
    @IBOutlet weak var EmailLineView: UIView!
    @IBOutlet weak var ErrorTopConstraint: NSLayoutConstraint!
   
    @IBAction func LoginAction(_ sender: AnyObject) {
        if !accounterror {
            accountErrorLabel.isHidden = false
            EmailLineView.backgroundColor = UIColor.red
            ErrorTopConstraint.constant = 40
            
            
        }
        
    }
    @IBAction func SignupAction(_ sender: AnyObject) {
        
        
        
    }
    
    private func initialFromXib(){
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "AccountView", bundle: bundle)
        contenView = nib.instantiate(withOwner: self, options: nil)[0] as!UIView
        contenView.frame = bounds
        addSubview(contenView)
    
    }
    
}
