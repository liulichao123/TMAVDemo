//
//  ViewController.m
//  TMAVDemo
//
//  Created by 天明 on 2017/7/21.
//  Copyright © 2017年 天明. All rights reserved.
//

#import "ViewController.h"
#import "TMSystemCapture.h"
#import "FLVAnalysisTool.h"
#import "TMAudioEncoder.h"
#import "TMAudioDecoder.h"
#import "TMAudioDataQueue.h"
#import "TMAudioPCMPlayer.h"
#import "TMAVConfig.h"


@interface ViewController () <TMSystemCaptureDelegate, TMAudioEncoderDelegate, TMAudioDecoderDelegate>
@property (nonatomic, strong) TMSystemCapture *capture;
@property (nonatomic, strong) TMAudioEncoder *audioEncoder;
@property (nonatomic, strong) TMAudioDecoder *audioDecoder;
@property(nonatomic, strong) TMAudioPCMPlayer *pcmPalyer;

@property (nonatomic, strong) NSFileHandle *handle;
@property (nonatomic, copy) NSString *path;

@end

@implementation ViewController

/**
 该项目功能：
 实时音视频捕获（数据流），硬编码成aac数据，在解码成pcm ，使用audioQueue播放
 **/
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self testFLV];
    
//    [self testAudio];
    
    
}

//测试解析flv
- (void)testFLV {
    FLVAnalysisTool *tool = [[FLVAnalysisTool alloc] init];
    [tool test];
}

//音频测试
- (void)testAudio {
    //    测试写入文件
    //    _path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"test.aac"];
    //    NSFileManager *manager = [NSFileManager defaultManager];
    //    if ([manager fileExistsAtPath:_path]) {
    //        if ([manager removeItemAtPath:_path error:nil]) {
    //            NSLog(@"删除成功");
    //            if ([manager createFileAtPath:_path contents:nil attributes:nil]) {
    //                NSLog(@"创建文件");
    //            }
    //        }
    //    }
    //
    //     NSLog(@"%@", _path);
    //    _handle = [NSFileHandle fileHandleForWritingAtPath:_path];
    
    //捕获媒体
    _capture = [[TMSystemCapture alloc] initWithType:TMSystemCaptureTypeAudio];//这是我只捕获了音频
    [_capture prepare];
    self.capture.delegate = self;
    
    //aac编码器
    _audioEncoder = [[TMAudioEncoder alloc] initWithConfig:[TMAudioConfig defaultConifg]];
    _audioEncoder.delegate = self;
    
    //aac解码器
    _audioDecoder = [[TMAudioDecoder alloc] initWithConfig:[TMAudioConfig defaultConifg]];
    _audioDecoder.delegate = self;
    
    //pcm播放器
    _pcmPalyer = [[TMAudioPCMPlayer alloc] initWithConfig:[TMAudioConfig defaultConifg]];
}


//MARK: delegate
//捕获音视频回调
- (void)captureAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    [_audioEncoder encodeAudioSamepleBuffer:sampleBuffer];
    
//    测试直播播放
//    NSData *pcmData = [self convertAudioSamepleBufferToPcmData:sampleBuffer];
//    [_pcmPalyer palyePCMData:pcmData];
   
}

//aac编码回调
- (void)encoderCallback:(NSData *)aacData {
    [_audioDecoder decodeAudioAACData:aacData];
    
//    测试写入文件
//    [_handle seekToEndOfFile];
//    [_handle writeData:aacData];
}

//aac解码回调
- (void)decoderCallback:(NSData *)pcmData {
    [_pcmPalyer playPCMData:pcmData];
}

//MARK: Action

//开始捕获
- (IBAction)start:(id)sender {
     [self.capture start];
}
//停止捕获
- (IBAction)stop:(id)sender {
    [self.capture stop];
}

//关闭文件
- (IBAction)close:(id)sender {
    [_handle closeFile];
}

// smapleBuffer -> pcmData
- (NSData *)convertAudioSamepleBufferToPcmData: (CMSampleBufferRef)sampleBuffer {
    //获取pcm数据大小
    size_t size = CMSampleBufferGetTotalSampleSize(sampleBuffer);
    
    //分配空间
    int8_t *audio_data = (int8_t *)malloc(size);
    memset(audio_data, 0, size);
    
    //获取CMBlockBuffer, 这里面保存了PCM数据
    CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    //将数据copy到我们分配的空间中
    CMBlockBufferCopyDataBytes(blockBuffer, 0, size, audio_data);
    NSData *data = [NSData dataWithBytes:audio_data length:size];
    free(audio_data);
    return data;
}

- (AudioStreamBasicDescription)getDesc:(CMSampleBufferRef)sampleBuffer {
     AudioStreamBasicDescription inputAduioDes = *CMAudioFormatDescriptionGetStreamBasicDescription( CMSampleBufferGetFormatDescription(sampleBuffer));
    return inputAduioDes;
}

@end



