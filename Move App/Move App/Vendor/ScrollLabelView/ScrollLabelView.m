//
//  ScrollLabelView.m
//  ScrollLabel
//
//  Created by zhao on 16/9/10.
//  Copyright © 2016年 zhao. All rights reserved.
//

#import "ScrollLabelView.h"

@interface ScrollLabelView ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *mainLabel;

@end

@implementation ScrollLabelView

- (instancetype)init
{
    if([super init])
    {
        [self initData];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if([super initWithFrame:frame])
    {
        [self initData];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if([super initWithCoder:aDecoder])
    {
        [self initData];
    }
    return self;
}

- (void)initData
{
    self.textFont = [UIFont systemFontOfSize:15];
    self.textColor = [UIColor blackColor];
    
    self.velocity = 16.0;
    self.pauseTimeIntervalBeforeScroll = 3;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self addSubview:self.scrollView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -- 滚动设置

- (void)setText:(NSString *)theText
{
    if([self.text isEqualToString:theText]) return;
    
    _text = theText;
    _mainLabel.text = theText;
    
    [self refreshLabelsFrame:theText];
}

/**
 *  根据Label的内容更新Label的frame
 */
- (void)refreshLabelsFrame:(NSString *)labelText
{
    if(labelText.length == 0) return;
    
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    
    
    CGSize labelSize = [labelText boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.textFont} context:nil].size;
    
    _mainLabel.frame = CGRectMake(0, 0, labelSize.width, height);
    
    self.scrollView.contentSize = CGSizeZero;
    [self.scrollView.layer removeAllAnimations];
    
    if(labelSize.width > width) {
        self.scrollView.contentSize = CGSizeMake(_mainLabel.frame.size.width, height);
        [self scrollLabelIfNeed];
    }else{
        self.scrollView.contentSize = self.bounds.size;
        [self.scrollView.layer removeAllAnimations];
    }
}

/**
 *  循环滚动Label
 */
- (void)scrollLabelIfNeed
{
    NSTimeInterval duration = (self.mainLabel.frame.size.width - self.frame.size.width)/self.velocity;
    if (duration < 0)  return;
    
    [self.scrollView.layer removeAllAnimations];
    //重置contentOffset 否则不会循环滚动
    self.scrollView.contentOffset = CGPointZero;
    
    [UIView animateWithDuration:duration delay:self.pauseTimeIntervalBeforeScroll options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
        
        self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.mainLabel.frame), 0);
    } completion:^(BOOL finished) {
        if(finished) {
            [self scrollLabelIfNeed];
        }
    }];
}

#pragma mark -- 进入后台 前台

- (void)addObaserverNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //活跃状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollLabelIfNeed) name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark --  getter

- (UIScrollView *)scrollView
{
    if(!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        _mainLabel = [[UILabel alloc] init];
        _mainLabel.textAlignment = NSTextAlignmentLeft;
        _mainLabel.font = self.textFont;
        _mainLabel.textColor = self.textColor;
        [self.scrollView addSubview:_mainLabel];
    }
    
    return _scrollView;
}



@end
