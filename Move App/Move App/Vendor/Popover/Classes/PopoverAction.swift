//
//  PopoverAction.swift
//  test
//
//  Created by Jiang Duan on 17/2/14.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

protocol PopoverAction {
    
    var imageUrl: String?   {get}                    ///< 图标URL
    var placeholderImage: UIImage? {get}             ///< 占位图标 (建议使用 60pix*60pix 的图片)
    var title: String? {get}                         ///< 标题
    
    var handler: ((PopoverAction) -> Void)? {get}    ///< 选中时回调
    
    var canAvatar: Bool {get}                        ///< 是否文字头像
    var isSelected: Bool {get set}                     ///< 是选中的？
    
    init(imageUrl: String?,
        placeholderImage: UIImage?,
        title: String?,
        isSelected: Bool,
        handler: ((PopoverAction) -> Void)?)
    
    
}

class BasePopoverAction: PopoverAction {

    var imageUrl: String?
    var placeholderImage: UIImage?
    var title: String?
    
    var handler: ((PopoverAction) -> Void)?
    
    var canAvatar: Bool = false
    var isSelected: Bool = false
    
    var data: Any?
    
    required init (imageUrl: String? = nil,
          placeholderImage: UIImage? = nil,
          title: String? = nil,
          isSelected: Bool = false,
          handler: ((PopoverAction) -> Void)? = nil) {
        
        self.imageUrl = imageUrl
        self.placeholderImage = placeholderImage
        self.title = title ?? ""
        self.handler = handler
    }
}
