//
//  FLVTags.m
//  TMAVDemo
//
//  Created by 天明 on 2017/8/16.
//  Copyright © 2017年 天明. All rights reserved.
//

#import "FLV_Header.h"

@implementation FLV_Header

+ (FLV_Header *)header {
    return [[FLV_Header alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _f = 0x46;
        _l = 0x4c;
        _v = 0x56;
        _vertion = 0x01;
        _flag = 0x04;
        _headerSize = 9;//4 byte
    }
    return self;
}

- (int)length {
    return 9;
}

- (NSData *)toBigData {
    int8_t *headerData = malloc(_headerSize);
    memset(headerData, 0, _headerSize);
    
    //FLV
    *headerData = _f;
    ++headerData;
    *headerData = _l;
    ++headerData;
    *headerData = _v;
    
    //version
    ++headerData;
    *headerData = _vertion;
    
    //flag
    ++headerData;
    *headerData = _flag;
    
    //headerSize
    ++headerData;
    uint32_t headerSize = htonl(_headerSize);
    memcpy(headerData, &headerSize, 4);
    
    //回到起点
    headerData -= 5;
    
    NSData *data = [NSData dataWithBytes:headerData length:_headerSize];
    free(headerData);
    
    return data;
}

@end




