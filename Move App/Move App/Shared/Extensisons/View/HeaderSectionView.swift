//
//  HeaderSectionView.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/8.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class ViewUtils {

    final class func viewForHeaderInSection(text: String) -> UIView? {
        let rect = CGRect(x: 20.0, y: 0.0, width: 300.0, height: 44.0)
        
        let label: UILabel = {
            $0.backgroundColor = UIColor.clear
            $0.isOpaque = false
            $0.textColor = UIColor.lightGray
            $0.highlightedTextColor = UIColor.white
            $0.font = UIFont.systemFont(ofSize: 15.0)
            $0.frame = rect
            $0.frame.origin.y += 22.0
            $0.text = text
            return $0
        } (UILabel())
        
        
        
        let view = UIView(frame: rect)
        view.addSubview(label)
        return view
    }
}
