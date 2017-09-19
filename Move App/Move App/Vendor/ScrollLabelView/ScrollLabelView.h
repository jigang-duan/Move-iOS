//
//  ScrollLabelView.h
//  ScrollLabel
//
//  Created by zhao on 16/9/10.
//  Copyright © 2016年 zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollLabelView : UIView

@property (nonatomic, strong) NSString *text; /**< 文字*/
@property (nonatomic, strong) UIColor *textColor; /**< 字体颜色 默认白色  黑*/
@property (nonatomic, strong) UIFont *textFont; /**< 字体大小 默认25  15*/
@property (nonatomic, assign) CGFloat velocity; /**< 滚动速度 pixels/second*/
@property (nonatomic, assign) NSTimeInterval pauseTimeIntervalBeforeScroll; /**< 每次开始滚动前暂停的间隔 默认3s*/

/**
 *  重新进入前台，还能滚动
 */
-(void)addObaserverNotification;
-(void)scrollLabelIfNeed;

@end
