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

#pragma mark 获取音量值
- (int)detectionVoice
{
    [_recorder updateMeters];//刷新音量数据
    //获取音量的平均值  [recorder averagePowerForChannel:0];
    //音量的最大值  [recorder peakPowerForChannel:0];
    
//    double lowPassResults = pow(10, (0.05 * [_recorder peakPowerForChannel:0]));
//    
//    if (0<lowPassResults<=0.27) {
//        return 1;
//    }else if (0.27<lowPassResults<=0.34) {
//        return 2;
//    }else if (0.34<lowPassResults<=0.41) {
//        return 3;
//    }else if (0.41<lowPassResults<=0.48) {
//        return 4;
//    }else if (0.48<lowPassResults<=0.55) {
//        return 5;
//    }else if (0.55<lowPassResults) {
//        return 6;
//    }
//    
//    return 0;
    
    float   level;                // The linear 0.0 .. 1.0 value we need.
    float   minDecibels = -80.0f; // Or use -60dB, which I measured in a silent room.
    float   decibels    = [_recorder averagePowerForChannel:0];
    
    if (decibels < minDecibels) {
        level = 0.0f;
    } else if (decibels >= 0.0f) {
        level = 1.0f;
    } else {
        float   root            = 2.0f;
        float   minAmp          = powf(10.0f, 0.05f * minDecibels);
        float   inverseAmpRange = 1.0f / (1.0f - minAmp);
        float   amp             = powf(10.0f, 0.05f * decibels);
        float   adjAmp          = (amp - minAmp) * inverseAmpRange;
        
        level = powf(adjAmp, 1.0f / root);
    }
    if ((0<level) && (level<=0.17)) {
        return 1;
    }else if ((0.17<level) && (level<=0.34)) {
        return 2;
    }else if ((0.34<level) && (level<=0.51)) {
        return 3;
    }else if ((0.51<level) && (level<=0.68)) {
        return 4;
    }else if ((0.68<level) && (level<=0.85)) {
        return 5;
    }else if (0.85<level) {
        return 6;
    }
    
    return 0;
    
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
