//
//  TMAudioConfig.m
//  TMAVDemo
//
//  Created by 天明 on 2017/7/21.
//  Copyright © 2017年 天明. All rights reserved.
//

#import "TMAVConfig.h"

@implementation TMAudioConfig

+ (instancetype)defaultConifg {
    return  [[TMAudioConfig alloc] init];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.bitrate = 96000;
        self.channelCount = 1;
        self.sampleSize = 16;
        self.sampleRate = 44100;
    }
    return self;
}
@end


@implementation TMVideoConfig

+ (instancetype)defaultConifg {
    return [[TMVideoConfig alloc] init];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.width = 480;
        self.height = 640;
        self.bitrate = 640*1000;
        self.fps = 25;
    }
    return self;
}
@end
