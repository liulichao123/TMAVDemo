//
//  TMAudioConfig.h
//  TMAVDemo
//
//  Created by 天明 on 2017/7/21.
//  Copyright © 2017年 天明. All rights reserved.
//  音视频配置

#import <Foundation/Foundation.h>

/**音频配置*/
@interface TMAudioConfig : NSObject
/**码率*/
@property (nonatomic, assign) NSInteger bitrate;//96000）
/**声道*/
@property (nonatomic, assign) NSInteger channelCount;//（1）
/**采样率*/
@property (nonatomic, assign) NSInteger sampleRate;//(默认44100)
/**采样点量化*/
@property (nonatomic, assign) NSInteger sampleSize;//(16)

+ (instancetype)defaultConifg;
@end

@interface TMVideoConfig : NSObject
@property (nonatomic, assign) NSInteger width;//可选，系统支持的分辨率，采集分辨率的宽
@property (nonatomic, assign) NSInteger height;//可选，系统支持的分辨率，采集分辨率的高
@property (nonatomic, assign) NSInteger bitrate;//自由设置
@property (nonatomic, assign) NSInteger fps;//自由设置 25
+ (instancetype)defaultConifg;
@end
