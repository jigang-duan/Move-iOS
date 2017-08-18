//
//  MoreView.swift
//  Move App
//
//  Created by jiang.duan on 2017/4/17.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

@objc
protocol MoreViewDelegate {
    
    @objc optional func delete(moreView: MoreView, items: [Int])
    
    @objc optional func clearAll(moreView: MoreView)
    @objc optional func multipleChoice(moreView: MoreView) -> [Int]
    
    @objc optional func complete(moreView: MoreView)
}

class MoreView: UIView {
    
    lazy var clearAllBtn: UIButton = {
        let $ = UIButton(type: .custom)
        $.frame = CGRect(x: 5, y: 5, width: 90, height: 30)
        $.setTitleColor(#colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1), for: .normal)
        $.setTitleColor(#colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 0.5), for: .highlighted)
        $.setTitle(R.string.localizable.id_delete_all(), for: .normal)
        $.sizeToFit()
        return $
    }()
    
    lazy var deleteBtn: UIButton = {
        let $ = UIButton(type: .custom)
        $.frame = CGRect(x: Main_Screen_Width - 40, y: 5, width: 30, height: 30)
        $.setImage(UIImage(named: "general_btn_del_nor"), for: .normal)
        $.setImage(UIImage(named: "general_btn_del_pre"), for: .highlighted)
        return $
    }()
    
    @IBOutlet var delegate: MoreViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        self.addSubview(clearAllBtn)
        self.addSubview(deleteBtn)
        clearAllBtn.addTarget(self, action: #selector(clearAllPressed(_:)), for: .touchUpInside)
        deleteBtn.addTarget(self, action: #selector(deletePressed(_:)), for: .touchUpInside)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let frame = defaultFrame
        self.init(frame: frame)
    }
    
    @objc fileprivate func clearAllPressed(_ sender: UIButton) {
        self.delegate?.clearAll?(moreView: self)
        self.delegate?.complete?(moreView: self)
    }
    
    @objc fileprivate func deletePressed(_ sender: UIButton) {
        let items = self.delegate?.multipleChoice?(moreView: self) ?? []
        self.delegate?.delete?(moreView: self, items: items)
        self.delegate?.complete?(moreView: self)
    }
    
}


fileprivate let defaultFrame = CGRect(x: 0, y: Main_Screen_Height - 40 - 64, width: Main_Screen_Width, height: 40)
fileprivate let unfoldFrame  = CGRect(x: 0, y: Main_Screen_Height - 168 - 64, width: Main_Screen_Width, height: 168)

fileprivate let Main_Screen_Height = UIScreen.main.bounds.size.height
fileprivate let Main_Screen_Width = UIScreen.main.bounds.size.width
