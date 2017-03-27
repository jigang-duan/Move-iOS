//
//  AmrRecorder.m
//  Move App
//
//  Created by jiang.duan on 2017/3/27.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "AmrRecorder.h"
#import "amrFileCodec.h"


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
    NSURL *url = [NSURL fileURLWithPath:[self cafPath]];
    
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    //录音格式 无法使用
    [settings setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    //采样率
    [settings setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];      //11025.0
    //通道数
    [settings setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    //音频质量,采样质量
    [settings setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    
    _recorder = [[AVAudioRecorder alloc] initWithURL:url
                                            settings:settings
                                               error:&recorderSetupError];
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
    NSString *cafFilePath = [self cafPath];
    NSString *amrFilePath = [self amrPath];
    
    // 删除旧的amr文件
    [self deleteAmrCache];
    
    NSLog(@"Amr转换开始");
    if (_delegate && [_delegate respondsToSelector:@selector(beginConvert)]) {
        [_delegate beginConvert];
    }
    
    @try {
        EncodeWAVEFileToAMRFile([cafFilePath cStringUsingEncoding:NSASCIIStringEncoding], [amrFilePath cStringUsingEncoding:NSASCIIStringEncoding], 2, 16);
        
    } @catch (NSException *exception) {
        NSLog(@"%@", [exception description]);
    } @finally {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    }
    
    [self deleteCafCache];
    NSLog(@"Amr转换结束");
    if (_delegate && [_delegate respondsToSelector:@selector(endConvertWithData:)]) {
        NSData *voiceData = [NSData dataWithContentsOfFile:[self amrPath]];
        [_delegate endConvertWithData:voiceData];
    }
    
}


#pragma mark - Path Utils
- (NSString *)cafPath
{
    NSString *cafPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.caf"];
    return cafPath;
}

- (NSString *)amrPath
{
    NSString *mp3Path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"amr.caf"];
    return mp3Path;
}

- (void)deleteAmrCache
{
    [self deleteFileWithPath:[self amrPath]];
}

- (void)deleteCafCache
{
    [self deleteFileWithPath:[self cafPath]];
}

- (void)deleteFileWithPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager removeItemAtPath:path error:nil]) {
        NSLog(@"删除旧的amr文件");
    }
}

@end
