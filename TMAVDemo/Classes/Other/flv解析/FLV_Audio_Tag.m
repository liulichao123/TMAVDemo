//
//  FLV_Audio_Tag.m
//  TMAVDemo
//
//  Created by 天明 on 2017/8/17.
//  Copyright © 2017年 天明. All rights reserved.
//

#import "FLV_Audio_Tag.h"

@implementation FLV_Audio_Tag

-(instancetype)initWithData: (NSData *)data;
{
    self = [super init];
    if (self) {
        self.type = 0x08;
        self.dataSize = (uint32_t)data.length;
        self.timestamp = 0;
        self.timestamp_ex = 0;
        self.streamsID = 0;
        
        //下面为AAC默认
        _formate = 10;//AAC
        _sampleRate = 3;
        _samplelen = 1;
        _audioType = 1;
        
        _data = data;
    }
    return self;
}

- (NSUInteger)allLength {
    return 11 +  1 + _data.length;
}

- (NSData *)toBigData {

    NSUInteger len = 11 +  1 + _data.length;
    int8_t *pData = malloc(len);
    memset(pData, 0, len);
    
    //base
    uint8_t type = self.type;
    memcpy(pData, &type, 1);
    
    pData++;
    uint32_t dataSize = htonl(self.dataSize) >> 8;
    memcpy(pData, &dataSize, 3);
    
    pData += 3;
    uint32_t timestamp = htonl(self.timestamp) >> 8;
    memcpy(pData, &timestamp, 3);
    
    pData += 3;
    uint8_t timestamp_ex = self.timestamp_ex;
    memcpy(pData, &timestamp_ex, 1);
    
    pData++;
    uint32_t streamsID = htonl(self.streamsID) >> 8;
    memcpy(pData, &streamsID, 3);
    
    //audio 1byte
    pData += 3;
    uint8_t audio = 0;
    audio = audio & (self.formate<< 4) ;
    audio = audio & (self.sampleRate << 2);
    audio = audio & (self.sampleRate << 1);
    audio = audio & self.audioType;
    memcpy(pData, &audio, 1);
    
    pData++;
    memcpy(pData, self.data.bytes, self.data.length);
    
    pData -= 12;
//    NSData *data = [NSData dataWithBytes:pData length:len];
    
    NSData *data = [[NSData alloc] initWithBytes:pData length:len];
    free(pData);//这里可以释放吗
    return data;
}

@end
