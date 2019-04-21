//
//  FLV_Audio_Tag.h
//  TMAVDemo
//
//  Created by 天明 on 2017/8/17.
//  Copyright © 2017年 天明. All rights reserved.
//

#import "FLV_Base_Tag.h"

@interface FLV_Audio_Tag : FLV_Base_Tag
@property (nonatomic, assign) uint8_t formate; //4 bit 音频格式
@property (nonatomic, assign) uint8_t sampleRate; //2 bit 采样率
@property (nonatomic, assign) uint8_t samplelen; //1 bit 采样长度
@property (nonatomic, assign) uint8_t audioType; //1 bit //音频类型
@property (nonatomic, strong) NSData *data; //数据区(data)	由数据区长度决定	数据实体

- (NSUInteger)allLength;

-(instancetype)initWithData: (NSData *)data;

@end
