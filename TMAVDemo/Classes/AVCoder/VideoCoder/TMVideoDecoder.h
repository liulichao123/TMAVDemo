//
//  TMVideoDecoder.h
//  TMAVDemo
//
//  Created by 天明 on 2017/8/13.
//  Copyright © 2017年 天明. All rights reserved.
//  h264解码器

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "TMAVConfig.h"

/**h264编码回调代理*/
@protocol TMVideoDecoderDelegate <NSObject>
- (void)videoDecodeCallback:(CVPixelBufferRef)imageBuffer;
@end

/**h264解码器 解码和回调均是异步队列*/
@interface TMVideoDecoder : NSObject
@property (nonatomic, strong) TMVideoConfig *config;
@property (nonatomic, weak) id<TMVideoDecoderDelegate> delegate;

- (instancetype)initWithConfig:(TMVideoConfig*)config;
/**解码h264数据*/
- (void)decodeNaluData:(NSData *)frame;

@end
