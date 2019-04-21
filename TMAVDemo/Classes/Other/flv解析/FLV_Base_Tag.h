//
//  FLV_Header_Common.h
//  TMAVDemo
//
//  Created by 天明 on 2017/8/17.
//  Copyright © 2017年 天明. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLV_Base_Tag : NSObject
@property (nonatomic, assign) int8_t type;//1 byte	0x08：音频; 0x09：视频; 0x12：脚本; 其他：保留
@property (nonatomic, assign) uint32_t dataSize; //3 byte 在数据区的长度
@property (nonatomic, assign) uint32_t timestamp;//3 byte 时间戳
@property (nonatomic, assign) int8_t timestamp_ex;//1 byte 时间戳扩展 将时间戳扩展为4bytes，代表高8位。很少用到
@property (nonatomic, assign) uint32_t streamsID; //3 btye StreamsID 总是 0

-(NSData *)toBigData;
@end

