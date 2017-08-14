//
//  TMAudioEncoder.h
//  TMAVDemo
//
//  Created by 天明 on 2017/7/22.
//  Copyright © 2017年 天明. All rights reserved.
//  AAC硬编码

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class TMAudioConfig;

/**AAC编码器代理*/
@protocol TMAudioEncoderDelegate <NSObject>
- (void)audioEncodeCallback:(NSData *)aacData;
@end

/**AAC硬编码器*/
@interface TMAudioEncoder : NSObject
/**编码器配置*/
@property (nonatomic, strong) TMAudioConfig *config;
@property (nonatomic, weak) id<TMAudioEncoderDelegate> delegate;

/**初始化传入编码器配置*/
- (instancetype)initWithConfig:(TMAudioConfig*)config;

- (void)encodeAudioSamepleBuffer: (CMSampleBufferRef)sampleBuffer;
@end
