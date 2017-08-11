//
//  TMAudioConfig.h
//  TMAVDemo
//
//  Created by 天明 on 2017/7/21.
//  Copyright © 2017年 天明. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMAudioConfig : NSObject
@property (nonatomic, unsafe_unretained) NSInteger bitrate;//可自由设置
@property (nonatomic, unsafe_unretained) NSInteger channelCount;//可选 1 2
@property (nonatomic, unsafe_unretained) NSInteger sampleRate;//可选 44100（默认） 22050 11025 5500
@property (nonatomic, unsafe_unretained) NSInteger sampleSize;//可选 16 8

+ (instancetype)defaultConifg;
@end

@interface TMVideoConfig : NSObject
@property (nonatomic, unsafe_unretained) NSInteger width;//可选，系统支持的分辨率，采集分辨率的宽
@property (nonatomic, unsafe_unretained) NSInteger height;//可选，系统支持的分辨率，采集分辨率的高
@property (nonatomic, unsafe_unretained) NSInteger bitrate;//自由设置
@property (nonatomic, unsafe_unretained) NSInteger fps;//自由设置 25 30 60
+ (instancetype)defaultConifg;
@end
