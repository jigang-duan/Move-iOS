//
//  UUMessageFrame.swift
//  UUChat
//
//  Created by jiang.duan on 2017/3/2.
//  Copyright © 2017年 jiang.duan. All rights reserved.
//

import Foundation
import UIKit

let ChatMargin: CGFloat = 10       //间隔
let ChatIconWH: CGFloat = 44       //头像宽高height、width
let ChatPicWH: CGFloat = 200       //图片宽高
let ChatContentW: CGFloat = 180    //内容宽度

let ChatTimeMarginW: CGFloat = 15  //时间文本与边框间隔宽度方向
let ChatTimeMarginH: CGFloat = 10  //时间文本与边框间隔高度方向

let ChatContentTop: CGFloat = 15   //文本内容与按钮上边缘间隔
let ChatContentLeft: CGFloat = 25  //文本内容与按钮左边缘间隔
let ChatContentBottom: CGFloat = 15 //文本内容与按钮下边缘间隔
let ChatContentRight: CGFloat = 15 //文本内容与按钮右边缘间隔

let ChatTimeFont = UIFont.systemFont(ofSize: 11)     //时间字体
let ChatContentFont = UIFont.systemFont(ofSize: 14)  //内容字体

fileprivate extension CGFloat {
    static func _max(_ a: CGFloat, _ b: CGFloat) -> CGFloat {
        return a > b ? a : b
    }
}

struct UUMessageFrame {
    
    var nameF: CGRect
    var iconF: CGRect
    var timeF: CGRect
    var contentF: CGRect
    
    var cellHeight: CGFloat
    var message: UUMessage
    var isShowTime: Bool
    
    init(message: UUMessage) {
        
        self.message = message
        self.isShowTime = message.showDateLabel
        
        let screenW = UIScreen.main.bounds.size.width
        
        // 1、计算时间的位置
        self.timeF = CGRect.zero
        if self.isShowTime {
            let timeY = ChatMargin
            let timeSize = NSString(string: self.message.strTime)
                .boundingRect(with: CGSize(width: 300, height: 100),
                              options: .usesLineFragmentOrigin,
                              attributes: [NSFontAttributeName: ChatTimeFont],
                              context: nil).size
            let timeX = (screenW - timeSize.width) / 2
            self.timeF = CGRect(x: timeX, y: timeY, width: timeSize.width + ChatTimeMarginW, height: timeSize.height + ChatTimeMarginH)
        }
        
        // 2、计算头像位置
        var iconX = ChatMargin
        if self.message.from == .me {
            iconX = screenW - ChatMargin - ChatIconWH
        }
        let iconY = timeF.maxY + ChatMargin
        self.iconF = CGRect(x: iconX, y: iconY, width: ChatIconWH, height: ChatIconWH)
        
        // 3、计算name位置
        self.nameF = CGRect(x: iconX, y: iconY + ChatIconWH, width: ChatIconWH, height: 20)
        
        // 4、计算内容位置
        var contentX = self.iconF.maxX + ChatMargin
        let contentY = iconY
        
        //根据种类分
        var contenSize: CGSize
        switch message.type {
        case .text:
            contenSize = NSString(string: message.content.text!)
                .boundingRect(with: CGSize(width: ChatContentW, height: CGFloat.greatestFiniteMagnitude),
                              options: .usesLineFragmentOrigin,
                              attributes: [NSFontAttributeName: ChatContentFont],
                              context: nil).size
        case .picture:
            contenSize = CGSize(width: ChatPicWH, height: ChatPicWH)
        case .video:
            contenSize = CGSize(width: 120, height: 60)
        case .voice:
            contenSize = CGSize(width: 60, height: 20)
        }
        if message.from == .me {
            contentX = iconX - contenSize.width - ChatContentLeft - ChatContentRight - ChatMargin
        }
        self.contentF = CGRect(x: contentX, y: contentY,
                               width: contenSize.width + ChatContentLeft + ChatContentRight,
                               height: contenSize.height + ChatContentTop + ChatContentBottom)
        
        self.cellHeight = CGFloat._max(self.contentF.maxY, self.nameF.maxY) + ChatMargin
        
    }
    
}
