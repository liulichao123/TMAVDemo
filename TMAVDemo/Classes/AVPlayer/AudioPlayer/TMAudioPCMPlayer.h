//
//  AudioPCMPalyer.h
//  TMAVDemo
//
//  Created by 天明 on 2017/8/10.
//  Copyright © 2017年 天明. All rights reserved.
//  pcm 播放器

#import <Foundation/Foundation.h>
@class TMAudioConfig;

@interface TMAudioPCMPlayer : NSObject

- (instancetype)initWithConfig:(TMAudioConfig *)config;
/**播放pcm*/
- (void)playPCMData:(NSData *)data;
/** 设置音量增量 0.0 - 1.0 */
- (void)setupVoice:(Float32)gain;
/**销毁 */
- (void)dispose;
@end
