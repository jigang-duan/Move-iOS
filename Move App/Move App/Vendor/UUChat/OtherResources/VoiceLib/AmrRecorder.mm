//
//  AmrRecorder.m
//  Move App
//
//  Created by jiang.duan on 2017/3/27.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "AmrRecorder.h"
#import "VoiceConverter.h"


@interface AmrRecorder()<AVAudioRecorderDelegate>
@property (nonatomic, strong) AVAudioSession *session;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSString *path;
@end


@implementation AmrRecorder

#pragma mark - Init Methods

- (id)initWithDelegate:(id<AmrRecorderDelegate>)delegate
{
    if (self = [super init]) {
        _delegate = delegate;
        _path = [self amrPath];
    }
    return self;
}

- (void)setRecorder
{
    _recorder = nil;
    NSError *recorderSetupError = nil;
    NSURL *url = [NSURL fileURLWithPath:[self wavPath]];
    _recorder = [[AVAudioRecorder alloc] initWithURL: url
                                            settings: VoiceConverter.GetAudioRecorderSettingDict
                                               error: &recorderSetupError];
    if (recorderSetupError) {
        NSLog(@"%@", recorderSetupError);
    }
    
    _recorder.meteringEnabled = YES;
    _recorder.delegate = self;
    [_recorder prepareToRecord];
}

- (void)setSesstion
{
    _session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [_session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if (_session == nil) {
        NSLog(@"Error creating session: %@", [sessionError description]);
    } else {
        [_session setActive:YES error:nil];
    }
}

- (void)setSavePath:(NSString *)path
{
    self.path = path;
}

#pragma mark - Public Methods
- (void)startRecord
{
    [self setSesstion];
    [self setRecorder];
    [_recorder record];
}

- (void)stopRecord
{
    double cTime = _recorder.currentTime;
    [_recorder stop];
    
    if (cTime > 1.0) {
        [self audio_PCM2AMR];
    } else {
        [_recorder deleteRecording];
        if ([_delegate respondsToSelector:@selector(failRecord)]) {
            [_delegate failRecord];
        }
    }
}

- (void)cancelRecord
{
    [_recorder stop];
    [_recorder deleteRecording];
}

#pragma mark - Convert Utils
- (void)audio_PCM2AMR
{
    NSString *wavFilePath = [self wavPath];
    NSString *amrFilePath = [self amrPath];
    
    // 删除旧的amr文件
    [self deleteAmrCache];
    
    NSLog(@"Amr转换开始");
    if (_delegate && [_delegate respondsToSelector:@selector(beginConvert)]) {
        [_delegate beginConvert];
    }
    
    @try {
        [VoiceConverter ConvertWavToAmr:wavFilePath amrSavePath:amrFilePath];
    } @catch (NSException *exception) {
        NSLog(@"%@", [exception description]);
    } @finally {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    }
    
    [self deleteWavCache];
    NSLog(@"Amr转换结束");
    if (_delegate && [_delegate respondsToSelector:@selector(endAmrConvertOfFile:)]) {
        [_delegate endAmrConvertOfFile:[self amrPath]];
    }
    
}


#pragma mark - Path Utils
- (NSString *)wavPath
{
    NSString *wavPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.wav"];
    return wavPath;
}

- (NSString *)amrPath
{
    NSString *armPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"amr.wav"];
    return armPath;
}

- (void)deleteAmrCache
{
    [self deleteFileWithPath:[self amrPath]];
}

- (void)deleteWavCache
{
    [self deleteFileWithPath:[self wavPath]];
}

- (void)deleteFileWithPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager removeItemAtPath:path error:nil]) {
        NSLog(@"删除旧的amr文件");
    }
}

@end
