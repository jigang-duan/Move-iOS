//
//  CDFInitialsAvatar.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

public class CDFInitialsAvatar {
    
    private var frame: CGRect
    private var fullName: String
    private var backgroundColor: UIColor
    private var initialsColor: UIColor
    private var initialsFont: UIFont?
    
    public init(rect frame: CGRect, fullName: String) {
        self.frame = frame
        self.fullName = fullName
        self.backgroundColor = UIColor.lightGray
        self.initialsColor = UIColor.white
        self.initialsFont = nil
    }
    
    public func imageRepresentation() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, true, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            
            let backgroundColor = self.backgroundColor
            
            let initials = self.initials()
            let fontSize = frame.size.height / 1.8
            
            let rectanglePath = UIBezierPath(rect: CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height))
            backgroundColor.setFill()
            rectanglePath.fill()
            
            let initialsStringRect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
            let initialsStringStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            initialsStringStyle.alignment = NSTextAlignment.center
            let font = initialsFont ?? UIFont.systemFont(ofSize: fontSize)
            
            let initialsStringFontAttributes = [NSFontAttributeName: font,
                                                NSForegroundColorAttributeName: self.initialsColor,
                                                NSParagraphStyleAttributeName: initialsStringStyle] as [String : Any]
            
            let initialsStringTextHeight = initials.boundingRect(with: CGSize(width: initialsStringRect.size.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: initialsStringFontAttributes, context: nil).size.height
            context.saveGState()
            context.clip(to: initialsStringRect)
            initials.draw(in: CGRect(x: initialsStringRect.minX, y: initialsStringRect.minY + (initialsStringRect.height - initialsStringTextHeight)/2, width: initialsStringRect.width, height: initialsStringTextHeight), withAttributes: initialsStringFontAttributes)
            context.restoreGState()
            
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        return nil
    }
    
    private func initials() -> String {
        let words = self.fullName.components(separatedBy: CharacterSet.whitespaces)
        let initials = words.filter{
            $0.characters.count > 0
            }
            .map {
                $0.substring(to: $0.index($0.startIndex, offsetBy: 1))
            }
            .reduce("", {$0 + $1})
        
        return initials.characters.count > 2 ? initials.substring(to: initials.index(initials.startIndex, offsetBy: 2)) : initials
    }
}
