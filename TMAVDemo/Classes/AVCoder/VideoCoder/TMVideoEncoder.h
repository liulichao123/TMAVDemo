//
//  TMVideoEncoder.h
//  TMAVDemo
//
//  Created by 天明 on 2017/8/11.
//  Copyright © 2017年 天明. All rights reserved.
// h264硬编码

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/**h264编码回调代理*/
@protocol TMVideoEncoderDelegate <NSObject>
- (void)videoEncodeCallback:(NSData *)h264Data;
@end

/**h264硬编码器*/
@interface TMVideoEncoder : NSObject

@property (nonatomic, weak) id<TMVideoEncoderDelegate> delegate;

-(void)encodeSampleBuffer:(CMSampleBufferRef)smapleBuffer;

@end
