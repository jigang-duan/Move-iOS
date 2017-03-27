//
//  AmrRecorder.h
//  Move App
//
//  Created by jiang.duan on 2017/3/27.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

#ifndef AmrRecorder_h
#define AmrRecorder_h

#import <Foundation/Foundation.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "interf_dec.h"
#include "interf_enc.h"

@protocol AmrRecorderDelegate <NSObject>
- (void)failRecord;
- (void)beginConvert;
- (void)endConvertWithData:(NSData *)voiceData;
- (void)endCafConvertWithURL:(NSURL *)voiceURL;

@end

@interface AmrRecorder : NSObject
@property (nonatomic, weak) id<AmrRecorderDelegate> delegate;

- (id)initWithDelegate:(id<AmrRecorderDelegate>)delegate;
- (void)startRecord;
- (void)stopRecord;
- (void)cancelRecord;

@end


#endif /* AmrRecorder_h */
