//
//  FLVTestVC.m
//  TMAVDemo
//
//  Created by 天明 on 2017/8/17.
//  Copyright © 2017年 天明. All rights reserved.
//

#import "FLVTestVC.h"

#import "TMSystemCapture.h"
#import "TMAVConfig.h"
#import "TMAudioEncoder.h"

#import "FLV_Tags.h"
#import "FLVAnalysisTool.h"

@interface FLVTestVC () <TMSystemCaptureDelegate, TMAudioEncoderDelegate>
@property (nonatomic, strong) TMSystemCapture *capture;
@property (nonatomic, strong) TMAudioEncoder *audioEncoder;
@property (nonatomic, strong) NSFileHandle *handle;
@property (nonatomic, copy) NSString *path;
@end

@implementation FLVTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self testAudio];
//    [[[FLVAnalysisTool alloc] init] test];;
    
}
- (IBAction)start:(id)sender {
    [self.capture start];
}
- (IBAction)stop:(id)sender {
    [self.capture stop];
}


//音频测试
- (void)testAudio {
    //测试写入文件
    _path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"test.flv"];
    NSFileManager *manager = [NSFileManager defaultManager];
    FLV_Header *header = [FLV_Header header];
    if ([manager fileExistsAtPath:_path]) {
        if ([manager removeItemAtPath:_path error:nil]) {
            NSLog(@"删除成功");
            if ([manager createFileAtPath:_path contents:header.toBigData attributes:nil]) {
                NSLog(@"创建文件");
            }
        }
    }else {
        if ([manager createFileAtPath:_path contents:header.toBigData attributes:nil]) {
            NSLog(@"创建文件");
        }
    }
    
    NSLog(@"%@", _path);
    _handle = [NSFileHandle fileHandleForWritingAtPath:_path];
    
    [_handle seekToEndOfFile];
    UInt32 presizeB = htonl(presize);
    [_handle writeData:[NSData dataWithBytes:&presizeB length:4]];
    
    NSData *script = [[[FLV_Script_Tag alloc] init] toBigData];
    [_handle seekToEndOfFile];
    [_handle writeData:script];
    presize = htonl((UInt32)script.length);
    
    //捕获媒体
    _capture = [[TMSystemCapture alloc] initWithType:TMSystemCaptureTypeAudio];//这是我只捕获了音频
    [_capture prepare];
    self.capture.delegate = self;
    
    //aac编码器
    _audioEncoder = [[TMAudioEncoder alloc] initWithConfig:[TMAudioConfig defaultConifg]];
    _audioEncoder.delegate = self;

}



//MARK: delegate
/***********************************************************************/

//捕获音视频回调
- (void)captureSampleBuffer:(CMSampleBufferRef)sampleBuffer type: (TMSystemCaptureType)type {
    if (type == TMSystemCaptureTypeAudio) {
        [_audioEncoder encodeAudioSamepleBuffer:sampleBuffer];
    }else {
        
    }
}


/***********************************************************************/
static UInt32 presize = 0; //4 byte
static uint32_t timestamp = 0;

//aac编码回调
- (void)audioEncodeCallback:(NSData *)aacData {
    timestamp += 1024 * 1000 / _audioEncoder.config.sampleRate;
    FLV_Audio_Tag *audioTag = [[FLV_Audio_Tag alloc] initWithData:aacData];
    audioTag.timestamp = timestamp;
    
    [_handle seekToEndOfFile];
    [_handle writeData:audioTag.toBigData];
    
    presize = (UInt32)audioTag.allLength;
    UInt32 presizeB = htonl(presize);
    [_handle seekToEndOfFile];
    [_handle writeData:[NSData dataWithBytes:&presizeB length:4]];
}

@end
