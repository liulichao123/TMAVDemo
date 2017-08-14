//
//  TMVideoEncoder.h
//  TMAVDemo
//
//  Created by 天明 on 2017/8/11.
//  Copyright © 2017年 天明. All rights reserved.
// h264硬编码

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "TMAVConfig.h"

/**h264编码回调代理*/
@protocol TMVideoEncoderDelegate <NSObject>
- (void)videoEncodeCallback:(NSData *)h264Data;
- (void)videoEncodeCallbacksps:(NSData *)sps pps:(NSData *)pps;
@end

/**h264硬编码器 (编码和回调均在异步队列执行)*/
@interface TMVideoEncoder : NSObject
@property (nonatomic, strong) TMVideoConfig *config;
@property (nonatomic, weak) id<TMVideoEncoderDelegate> delegate;

- (instancetype)initWithConfig:(TMVideoConfig*)config;
/**编码*/
-(void)encodeVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end
