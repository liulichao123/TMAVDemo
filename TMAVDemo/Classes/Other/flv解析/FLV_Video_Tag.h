//
//  FLV_Video_Tag.h
//  TMAVDemo
//
//  Created by 天明 on 2017/8/17.
//  Copyright © 2017年 天明. All rights reserved.
//

#import "FLV_Base_Tag.h"

@interface FLV_Video_Tag : FLV_Base_Tag
@property (nonatomic, assign) uint8_t frameType; //4 bit 帧类型
@property (nonatomic, assign) uint8_t coderType; //4 bit 视频编码类型
@property (nonatomic, strong) NSData *data;
@end
