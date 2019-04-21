//
//  ViewController.m
//  TMAVDemo
//
//  Created by 天明 on 2017/7/21.
//  Copyright © 2017年 天明. All rights reserved.
//

#import "ViewController.h"

#import "FLVAnalysisTool.h"
#import "TMAudioDataQueue.h"

#import "TMSystemCapture.h"
#import "TMAVConfig.h"
#import "TMAudioEncoder.h"
#import "TMAudioDecoder.h"
#import "TMAudioPCMPlayer.h"
#import "TMVideoEncoder.h"
#import "TMVideoDecoder.h"
#import "AAPLEAGLLayer.h"


@interface ViewController () <TMSystemCaptureDelegate, TMAudioEncoderDelegate, TMAudioDecoderDelegate, TMVideoEncoderDelegate, TMVideoDecoderDelegate>

@property (nonatomic, strong) TMSystemCapture *capture;

@property (nonatomic, strong) TMAudioEncoder *audioEncoder;
@property (nonatomic, strong) TMAudioDecoder *audioDecoder;
@property(nonatomic, strong) TMAudioPCMPlayer *pcmPalyer;

@property (nonatomic, strong) TMVideoEncoder *videoEncoder;
@property (nonatomic, strong) TMVideoDecoder *videoDecoder;
@property (nonatomic, strong) AAPLEAGLLayer *displayLayer;

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
    
    
    [self testVideo];
}

//测试解析flv
- (void)testFLV {
    FLVAnalysisTool *tool = [[FLVAnalysisTool alloc] init];
    [tool test];
}

//音频测试
- (void)testAudio {
//        测试写入文件
        _path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"test.aac"];
        NSFileManager *manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:_path]) {
            if ([manager removeItemAtPath:_path error:nil]) {
                NSLog(@"删除成功");
                if ([manager createFileAtPath:_path contents:nil attributes:nil]) {
                    NSLog(@"创建文件");
                }
            }
        }else {
            if ([manager createFileAtPath:_path contents:nil attributes:nil]) {
                NSLog(@"创建文件");
            }
        }
    
         NSLog(@"%@", _path);
        _handle = [NSFileHandle fileHandleForWritingAtPath:_path];
    
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

- (void)testVideo {
    
//    测试写入文件
    _path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"h264test.h264"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:_path]) {
        if ([manager removeItemAtPath:_path error:nil]) {
            NSLog(@"删除成功");
            if ([manager createFileAtPath:_path contents:nil attributes:nil]) {
                NSLog(@"创建文件");
            }
        }
    }else {
        if ([manager createFileAtPath:_path contents:nil attributes:nil]) {
            NSLog(@"创建文件");
        }
    }

     NSLog(@"%@", _path);
    _handle = [NSFileHandle fileHandleForWritingAtPath:_path];
    [TMSystemCapture checkCameraAuthor];
    
    //捕获媒体
    _capture = [[TMSystemCapture alloc] initWithType:TMSystemCaptureTypeVideo];//这是我只捕获了视频
    CGSize size = CGSizeMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [_capture prepareWithPreviewSize:size];  //捕获视频时传入预览层大小
    _capture.preview.frame = CGRectMake(0, 100, size.width, size.height);
    [self.view addSubview:_capture.preview];
    self.capture.delegate = self;
    
    TMVideoConfig *config = [TMVideoConfig defaultConifg];
    config.width = _capture.witdh;
    config.height = _capture.height;
    config.bitrate = config.height * config.width * 5;
    
    _videoEncoder = [[TMVideoEncoder alloc] initWithConfig:config];
    _videoEncoder.delegate = self;
    
    _videoDecoder = [[TMVideoDecoder alloc] initWithConfig:config];
    _videoDecoder.delegate = self;
    
    _displayLayer = [[AAPLEAGLLayer alloc] initWithFrame:CGRectMake(size.width, 100, size.width, size.height)];
    [self.view.layer addSublayer:_displayLayer];
}
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

//MARK: delegate
/***********************************************************************/

//捕获音视频回调
- (void)captureSampleBuffer:(CMSampleBufferRef)sampleBuffer type: (TMSystemCaptureType)type {
    if (type == TMSystemCaptureTypeAudio) {
        //    测试直接播放
        //    NSData *pcmData = [self convertAudioSamepleBufferToPcmData:sampleBuffer];
        //    [_pcmPalyer palyePCMData:pcmData];
        
        [_audioEncoder encodeAudioSamepleBuffer:sampleBuffer];
    }else {
        [_videoEncoder encodeVideoSampleBuffer:sampleBuffer];
    }
}


/***********************************************************************/
//aac编码回调
- (void)audioEncodeCallback:(NSData *)aacData {
    [_audioDecoder decodeAudioAACData:aacData];
    
//    测试写入文件
//    [_handle seekToEndOfFile];
//    [_handle writeData:aacData];

}

//aac解码回调
- (void)audioDecodeCallback:(NSData *)pcmData {
    //解码后播放
    [_pcmPalyer playPCMData:pcmData];
}

//h264编码回调（sps/pps）
- (void)videoEncodeCallbacksps:(NSData *)sps pps:(NSData *)pps {
    //解码
    [_videoDecoder decodeNaluData:sps];
    [_videoDecoder decodeNaluData:pps];
    
    //测试写入文件
//    [_handle seekToEndOfFile];
//    [_handle writeData:sps];
//    [_handle seekToEndOfFile];
//    [_handle writeData:pps];
}
//h264编码回调 （数据）
- (void)videoEncodeCallback:(NSData *)h264Data {
    //编码
    [_videoDecoder decodeNaluData:h264Data];
    
//    测试写入文件
//    [_handle seekToEndOfFile];
//    [_handle writeData:h264Data];
}
//h264解码回调
- (void)videoDecodeCallback:(CVPixelBufferRef)imageBuffer {
    //显示
    if (imageBuffer) {
        _displayLayer.pixelBuffer = imageBuffer;
    }
    
}

/***********************************************************************/

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
- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end



