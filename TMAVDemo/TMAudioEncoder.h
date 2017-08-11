//
//  TMAudioEncoder.h
//  TMAVDemo
//
//  Created by 天明 on 2017/7/22.
//  Copyright © 2017年 天明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class TMAudioConfig;

@protocol TMAudioEncoderDelegate <NSObject>

- (void)encoderCallback:(NSData *)aacData;

@end

@interface TMAudioEncoder : NSObject
@property (nonatomic, strong) TMAudioConfig *config;
@property (nonatomic, weak) id<TMAudioEncoderDelegate> delegate;

//config 可为空，使用默认值
- (instancetype)initWithConfig:(TMAudioConfig*)config;

- (void)encodeAudioSamepleBuffer: (CMSampleBufferRef)sampleBuffer;
@end
