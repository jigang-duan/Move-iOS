//
//  ContactAnnotationView.swift
//  Move App
//
//  Created by lx on 17/3/3.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class ContactAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        let subview = Bundle.main.loadNibNamed("contactCell", owner: self, options: nil)?.first as! contactCell
        self.centerOffset = CGPoint(x : -40,y : -80)
        self.addSubview(subview)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
}
