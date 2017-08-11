//
//  TMAudioDecoder.h
//  TMAVDemo
//
//  Created by 天明 on 2017/8/9.
//  Copyright © 2017年 天明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class TMAudioConfig;

@protocol TMAudioDecoderDelegate <NSObject>

- (void)decoderCallback:(NSData *)pcmData;

@end

@interface TMAudioDecoder : NSObject
@property (nonatomic, strong) TMAudioConfig *config;
@property (nonatomic, weak) id<TMAudioDecoderDelegate> delegate;

//config 可为空，使用默认值
- (instancetype)initWithConfig:(TMAudioConfig *)config;

- (void)decodeAudioAACData: (NSData *)aacData;
@end
