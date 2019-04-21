//
//  FLV_Script_Tag.m
//  TMAVDemo
//
//  Created by 天明 on 2017/8/17.
//  Copyright © 2017年 天明. All rights reserved.
//

#import "FLV_Script_Tag.h"

@implementation FLV_Script_Tag

- (instancetype)init
{
    self = [super init];
    if (self) {
        //base
        self.type = 0x12;
        self.dataSize = 18 + 11 + 11 + 18;
        self.timestamp = 0;
        self.timestamp_ex = 0;
        self.streamsID = 0;
        _amf1_Type = 0x02;
        _onMetaData = @"onMetaData";
        _strlen = (uint16_t)_onMetaData.length;
        _amf2_Type = 0x08;
        _arrayCount = 0x00000003;
    }
    return self;
}

- (NSData *)toBigData {
    
    
    
    int allLen = 11 + 18 + 11 + 11 + 18;
    uint8_t *pData = malloc(allLen);
    
    //base 共11btye
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
    pData += 3;
    
    //afm1_type 1byte (0x02)
    uint8_t amf1_Type = _amf1_Type;
    memcmp(pData, &amf1_Type, 1);
    pData++;
    
    //key 的长度占 2 byte
    uint16_t keyLen = 10;
    keyLen = htons(keyLen);
    memcmp(pData, &keyLen, 2);
    pData += 2;
    
    //key 本身
    char *onMetaData = "onMetaData";
    memcmp(pData, onMetaData, keyLen);
    pData += 10;
    
    //amf2_type
    uint8_t amf2_type = _amf2_Type;
    memcmp(pData, &amf2_type, 1);
    pData++;
    
    //arrayCount
    uint32_t arrayCount = htonl(_arrayCount);
    memcmp(pData, &arrayCount, 4);
    pData += 4;
    //上面占 18 byte
    
    char *hasAudio = "hasAudio"; //1 byte
    char *hasVideo = "hasVideo"; //1 byte
    char *duration = "duration"; //8 byte

    // hasAudio  共 11 byte
    keyLen = 8;// 占 1 byte
    memcmp(pData, &keyLen, 1);
    pData++;
    memcmp(pData, hasAudio, keyLen);
    pData += 8;
    
    uint8_t valueType = 1; //boolean
    memcmp(pData, &valueType, 1);
    pData++;
    uint8_t boolValue = 1; //ture
    memcmp(pData, &boolValue, 1);
    pData++;
    
    // hasVideo 共 11 byte
    keyLen = 8;// 占 1 byte
    memcmp(pData, &keyLen, 1);
    pData++;
    memcmp(pData, hasVideo, keyLen);
    pData += 8;
    
    valueType = 1; //boolean
    memcmp(pData, &valueType, 1);
    pData++;
    boolValue = 0; //ture
    memcmp(pData, &boolValue, 1);
    pData++;
    
    // duration 共 18 byte
    keyLen = 8;// 占 1 byte
    memcmp(pData, &keyLen, 1);
    pData++;
    memcmp(pData, duration, keyLen);
    pData += 8;
    
    valueType = 0; //number (double)
    memcmp(pData, &valueType, 1);
    pData++;
    double doubleValue = 10.0; //ture
    double *pDouble = &doubleValue;
    char cValue[8];
    for (int i = 0; i < 8; i++) {
        cValue[7 - i] = pDouble[i];
    }
    memcmp(pData, cValue, 8);
    
    pData -= (allLen - 8);
    
    NSData *data = [[NSData alloc] initWithBytes:pData length:allLen];
    
    free(pData);
    return data;
}


@end
