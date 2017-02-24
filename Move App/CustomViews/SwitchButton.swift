//
//  SwitchButton.swift
//  LinkApp
//
//  Created by Jiang Duan on 17/1/5.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

@IBDesignable
public class SwitchButton: UIButton {
    
    @IBOutlet public weak var delegate: SwitchButtonDelegate?
    
    public var closureSwitch: ((Bool)->Void)?
    
    @IBInspectable public var isOn: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.6, animations: {
                self.setBackgroundImage(self.isOn ? self.onImage : self.offImage, for: .normal)
            })
        }
    }
    
    @IBInspectable public var onImage: UIImage?
    @IBInspectable public var offImage: UIImage?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
    }
    
    func tapped(_ sender: SwitchButton) {
        self.isOn = !self.isOn
        self.delegate?.didSwitchInButton?(on: self.isOn, sender: self)
        self.delegate?.didSwitch?(self, on: isOn)
        self.closureSwitch?(self.isOn)
    }
    
}

@objc
public protocol SwitchButtonDelegate {
    @objc optional func didSwitchInButton(on: Bool, sender: SwitchButton)
    @objc optional func didSwitch(_ sender: SwitchButton, on: Bool)
}
