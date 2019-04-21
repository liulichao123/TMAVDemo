//
//  FLV_Script_Tag.h
//  TMAVDemo
//
//  Created by 天明 on 2017/8/17.
//  Copyright © 2017年 天明. All rights reserved.
//

#import "FLV_Base_Tag.h"

@interface FLV_Script_Tag : FLV_Base_Tag
@property(nonatomic, assign) uint8_t amf1_Type; //1 byte
@property(nonatomic, assign) uint16_t strlen;   //2 byte
@property(nonatomic, copy) NSString *onMetaData; // strlen byte
@property(nonatomic, assign) uint8_t amf2_Type; //1 byte 0x08
@property(nonatomic, assign) uint32_t arrayCount; // 4 byte

- (NSData *)toBigData;
@end
