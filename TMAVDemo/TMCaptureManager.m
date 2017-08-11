//
//  TMCaptureManager.m
//  TMAVDemo
//
//  Created by 天明 on 2017/8/9.
//  Copyright © 2017年 天明. All rights reserved.
//

#import "TMCaptureManager.h"
#import "TMAudioEncoder.h"

@interface TMCaptureManager ()
@property (nonatomic, strong) TMAudioEncoder *audioEncoder;
//时间戳
@property (nonatomic, unsafe_unretained) uint32_t timestamp;

@end

@implementation TMCaptureManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
    }
    return self;
}

@end
