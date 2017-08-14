//
//  TMAudioDecoder.h
//  TMAVDemo
//
//  Created by 天明 on 2017/8/9.
//  Copyright © 2017年 天明. All rights reserved.
//  AAC 硬解码

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class TMAudioConfig;

/**AAC解码回调代理*/
@protocol TMAudioDecoderDelegate <NSObject>
- (void)audioDecodeCallback:(NSData *)pcmData;
@end

/**AAC解码器*/
@interface TMAudioDecoder : NSObject
@property (nonatomic, strong) TMAudioConfig *config;
@property (nonatomic, weak) id<TMAudioDecoderDelegate> delegate;

//初始化 传入解码配置
- (instancetype)initWithConfig:(TMAudioConfig *)config;

- (void)decodeAudioAACData: (NSData *)aacData;
@end
