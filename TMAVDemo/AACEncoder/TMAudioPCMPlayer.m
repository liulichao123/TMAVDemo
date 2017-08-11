//
//  AudioPCMPalyer.m
//  TMAVDemo
//
//  Created by 天明 on 2017/8/10.
//  Copyright © 2017年 天明. All rights reserved.
//

#import "TMAudioPCMPlayer.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "TMAVConfig.h"
#import "TMAudioDataQueue.h"
#define MIN_SIZE_PER_FRAME 2048 //每帧最小数据长度
static const int kNumberBuffers_play = 3;                              // 1
typedef struct AQPlayerState
{
    AudioStreamBasicDescription   mDataFormat;                    // 2
    AudioQueueRef                 mQueue;                         // 3
    AudioQueueBufferRef           mBuffers[kNumberBuffers_play];       // 4
    AudioStreamPacketDescription  *mPacketDescs;                  // 9
}AQPlayerState;

@interface TMAudioPCMPlayer ()
@property (nonatomic, assign) AQPlayerState aqps;
@property (nonatomic, strong) TMAudioConfig *config;
@property (nonatomic, assign) BOOL isPlaying;
@end

@implementation TMAudioPCMPlayer

static void TMAudioQueueOutputCallback(void * inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer) {
    //从队列中获取数据()
//    while (true) {
//        NSData *data = [[TMAudioDataQueue shareInstance] getData];
//        if (data) {
//            memset(inBuffer->mAudioData, 0, inBuffer->mAudioDataByteSize);
//            memcpy(inBuffer->mAudioData, data.bytes, data.length);
                //inBuffer->mAudioData 内存拷贝会导致内存泄漏
//            inBuffer->mAudioDataByteSize = (UInt32)data.length;
//            OSStatus status = AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
//            if (status != noErr) {
//                NSLog(@"Error: audio queue palyer  enqueue error: %d",(int)status);
//            }
//
//            return;
//        }
//        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
//    }
    //释放这个inBuffer,
    AudioQueueFreeBuffer(inAQ, inBuffer);
}

- (instancetype)initWithConfig:(TMAudioConfig *)config
{
    self = [super init];
    if (self) {
        _config = config;
        //配置
        AudioStreamBasicDescription dataFormat = {0};
        dataFormat.mSampleRate = (Float64)_config.sampleRate;       //采样率
        dataFormat.mChannelsPerFrame = (UInt32)_config.channelCount; //输出声道数
        dataFormat.mFormatID = kAudioFormatLinearPCM;                //输出格式
        dataFormat.mFormatFlags = (kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked); //编码 12
        dataFormat.mFramesPerPacket = 1;                            //每一个packet帧数 ；
        dataFormat.mBitsPerChannel = 16;                             //数据帧中每个通道的采样位数。
        dataFormat.mBytesPerFrame = dataFormat.mBitsPerChannel / 8 *dataFormat.mChannelsPerFrame;                              //每一帧大小（采样位数 / 8 *声道数）
        dataFormat.mBytesPerPacket = dataFormat.mBytesPerFrame * dataFormat.mFramesPerPacket;                             //每个packet大小（帧大小 * 帧数）
        dataFormat.mReserved =  0;
        AQPlayerState state = {0};
        state.mDataFormat = dataFormat;
        _aqps = state;
        
        [self setupSession];
        
        //创建播放队列
        OSStatus status = AudioQueueNewOutput(&_aqps.mDataFormat, TMAudioQueueOutputCallback, NULL, NULL, NULL, 0, &_aqps.mQueue);
        if (status != noErr) {
            NSError *error = [[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
            NSLog(@"Error: AudioQueue create error = %@", [error description]);
            return self;
        }
        
        [self setupVoice:1];
        _isPlaying = false;
    }
    return self;
}


- (void)setupSession {
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error) {
        NSLog(@"Error: audioQueue palyer AVAudioSession error, error: %@", error);
    }
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error) {
        NSLog(@"Error: audioQueue palyer AVAudioSession error, error: %@", error);
    }
}

- (void)playPCMData:(NSData *)data {
    AudioQueueBufferRef inBuffer;
    AudioQueueAllocateBuffer(_aqps.mQueue, MIN_SIZE_PER_FRAME, &inBuffer);
    memcpy(inBuffer->mAudioData, data.bytes, data.length);
    inBuffer->mAudioDataByteSize = (UInt32)data.length;
    OSStatus status = AudioQueueEnqueueBuffer(_aqps.mQueue, inBuffer, 0, NULL);
    if (status != noErr) {
        NSLog(@"Error: audio queue palyer  enqueue error: %d",(int)status);
    }
    AudioQueueStart(_aqps.mQueue, NULL);
}

//不需要该函数，
//- (void)pause {
//     AudioQueuePause(_aqps.mQueue);
//}

//设置音量增量//0.0 - 1.0
- (void)setupVoice:(Float32)gain {
    Float32 gain0 = gain;
    if (gain < 0) {
        gain0 = 0;
    }else if (gain > 1) {
        gain0 = 1;
    }
    AudioQueueSetParameter(_aqps.mQueue, kAudioQueueParam_Volume, gain0);
}
//销毁
- (void)dispose {
    AudioQueueStop(_aqps.mQueue, true);
    AudioQueueDispose(_aqps.mQueue, true);
}

@end
