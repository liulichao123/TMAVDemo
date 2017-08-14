//
//  TMSystemCapture.h
//  AudioAndVideoCapture
//
//  Created by mac on 2016/11/11.
//  Copyright © 2016年 刘立超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

//捕获类型
typedef NS_ENUM(int, TMSystemCaptureType){
    TMSystemCaptureTypeVideo = 0,
    TMSystemCaptureTypeAudio,
    TMSystemCaptureTypeAll
};

@protocol TMSystemCaptureDelegate <NSObject>
@optional
- (void)captureSampleBuffer:(CMSampleBufferRef)sampleBuffer type: (TMSystemCaptureType)type;

@end

/**捕获音视频*/
@interface TMSystemCapture : NSObject
/**预览层*/
@property (nonatomic, strong) UIView *preview;
@property (nonatomic, weak) id<TMSystemCaptureDelegate> delegate;
/**捕获视频的宽*/
@property (nonatomic, assign, readonly) NSUInteger witdh;
/**捕获视频的高*/
@property (nonatomic, assign, readonly) NSUInteger height;

- (instancetype)initWithType:(TMSystemCaptureType)type;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

/** 准备工作(只捕获音频时调用)*/
- (void)prepare;
//捕获内容包括视频时调用（预览层大小，添加到view上用来显示）
- (void)prepareWithPreviewSize:(CGSize)size;

/**开始*/
- (void)start;
/**结束*/
- (void)stop;
/**切换摄像头*/
- (void)changeCamera;


//授权检测
+ (int)checkMicrophoneAuthor;
+ (int)checkCameraAuthor;


/**示例：
 //只捕获音频
 _capture = [[TMSystemCapture alloc] initWithType:TMSystemCaptureTypeAudio];
 [_capture prepare];
 self.capture.delegate = self;
 [self.capture start];
 
 代理：
 - (void)captureAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    do something
 }
 **/

@end
