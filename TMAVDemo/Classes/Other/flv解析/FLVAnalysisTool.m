//
//  FLVAnalysisTool.m
//  TMAVDemo
//
//  Created by 天明 on 2017/8/3.
//  Copyright © 2017年 天明. All rights reserved.
//

#import "FLVAnalysisTool.h"

@implementation FLVAnalysisTool


- (void)test {
    NSString *path = @"/Users/quanzizhangben/Desktop/test.flv";
    NSData *fileData = [NSData dataWithContentsOfFile:path];
    
    //    [self decoderFLVHeader:[self createFLVHeader]];
    [self decoderFLV:fileData];
}

- (NSData *)createFLVHeader {
    int8_t *headerData = malloc(36);
    memset(headerData, 0, 36);
    
    int8_t signatureF = 0x46;
    int8_t signatureL = 0x4c;
    int8_t signatureV = 0x56;
    int8_t vertion = 1;
    int8_t flag = 0x04;
    int32_t headerSize = 9;//
    
    //FLV
    *headerData = signatureF;
    ++headerData;
    *headerData = signatureL;
    ++headerData;
    *headerData = signatureV;
    
    //version
    ++headerData;
    *headerData = vertion;
    
    //flag
    ++headerData;
    *headerData = flag;
    
    //headerSize
    ++headerData;
    *headerData = headerSize;
    
    headerData -= 5;
    
    return [NSData dataWithBytes:headerData length:9];
}

- (void)decoderFLVHeader: (NSData *)header {
    NSLog(@"-------------header-----------------");
    
    char *flv = malloc(3);
    int8_t vertion = 0;
    int8_t flag = 0;
    int32_t headerSize = 0;
    
    [header getBytes:flv length:3];
    NSLog(@"[flv]: %s", flv);
    
    [header getBytes:&vertion range:NSMakeRange(3, 1)];
    NSLog(@"[vertion]: %d", vertion);
    
    [header getBytes:&flag range:NSMakeRange(4, 1)];
    NSLog(@"[flag]: %d", flag);
    
    [header getBytes:&headerSize range:NSMakeRange(5, 4)];
    headerSize = ntohl(headerSize);
    NSLog(@"[headerSize]: %d", headerSize);
    free(flv);
    
    NSLog(@"-------------end header-----------------");
}

- (void)decoderFLV: (NSData *)data {
    NSData *header = [data subdataWithRange:NSMakeRange(0, 9)];
    [self decoderFLVHeader:header];
    NSUInteger index = 9;
    
    while (index < data.length - 5) {
        NSLog(@"--------------------Tag----------------");
        
        //preTagSize 4
        uint32_t preTagSize = 0;
        [data getBytes:&preTagSize range:NSMakeRange(index, 4)];
        preTagSize = ntohl(preTagSize);
        NSLog(@"[preTagSize]: %d", preTagSize);
        
        //tagType 1
        index += 4;
        int8_t tagType;
        [data getBytes:&tagType range:NSMakeRange(index, 1)];
        NSLog(@"[tagType]: %d", tagType);//留后面使用
        
        //dataSize 3
        index++;
        uint32_t dataSize = 0;
        [data getBytes:&dataSize range:NSMakeRange(index, 3)];
        dataSize = ntohl(dataSize) >> 8;
        NSLog(@"[dataSize]: %d", dataSize);
        
        //timeStamp 3
        index += 3;
        uint32_t timeStamp = 0;
        [data getBytes:&timeStamp range:NSMakeRange(index, 3)];
        timeStamp = ntohl(timeStamp) >> 8;
        NSLog(@"[timeStamp]: %d", timeStamp);
        
        //timeStamp_ex 1
        uint8_t timeStamp_ex = 0;
        index += 3;
        [data getBytes:&timeStamp_ex range:NSMakeRange(index, 1)];
        NSLog(@"[timeStamp_ex]: %d", timeStamp_ex);
        
        //streamID 3
        index++;
        uint32_t streamID = 0;
        [data getBytes:&streamID range:NSMakeRange(index, 3)];
        timeStamp = ntohl(streamID) >> 8;
        NSLog(@"[streamID]: %d", streamID);
        
        //tag data
        index += 3 ;
        if (tagType == 0x12) {
            NSLog(@"script data");
            uint8_t *p = (uint8_t *)malloc(dataSize);
            [data getBytes:p range:NSMakeRange(index, dataSize)];
            handleScriptData(p);
            free(p);
        }else if (tagType == 0x08) {
            NSLog(@"音频");
            uint8_t audioPre;
            [data getBytes:&audioPre range:NSMakeRange(index, 1)];
            handleAutioTagData(audioPre);
        }else if (tagType == 0x09) {
            NSLog(@"视频");
            uint8_t videoPre;
            [data getBytes:&videoPre range:NSMakeRange(index, 1)];
            handleVideoTagData(videoPre);
        }else{
            NSLog(@"other ...");
        }
        
        //next
        index += dataSize;
    }
    
}

void handleScriptData(uint8_t *sd) {
    NSLog(@"--------------ScriptData--------------------");
    uint8_t type = *sd;
    //    0 = Number type
    //    1 = Boolean type
    //    2 = String type
    //    3 = Object type
    //    4 = MovieClip type
    //    5 = Null type
    //    6 = Undefined type
    //    7 = Reference type
    //    8 = ECMA array type
    //    10 = Strict array type
    //    11 = Date type
    //    12 = Long string type
    
    //first AMF 包
    if (type != 0x02) return;
    NSLog(@"First AMF frame type: %d, String type", type);
    uint16_t strlen;
    sd++;
    memcpy(&strlen, sd, 2);
    strlen = ntohs(strlen);
    NSLog(@"String length = %d",strlen);
    char *onMetaData = (char *)malloc(strlen);
    sd += 2;
    memcpy(onMetaData, sd, strlen);
    NSLog(@"onMetaData : %s", onMetaData);
    free(onMetaData);
    
    //second AMF 包 0 + 2 + strlen(10)
    sd += strlen;
    type = *sd;
    if (type != 0x08) return;
    NSLog(@"Second AMF frame type: %d, ECMA array type", type);
    sd++;
    uint32_t arrayCount;
    memcpy(&arrayCount, sd, 4);
    arrayCount = ntohl(arrayCount);
    NSLog(@"ECMA array count: %d", arrayCount);
    sd += 4;
    
    NSLog(@"-------------------ECMA array map---------------------");
    uint16_t keyLen;
    uint8_t dataType;
    /**ECMA array里面的 map, key 都是string 类型，type都等于0x02,直接不用管即可，key前面的字节为key的长度，没有0x02
     里面是key-value形式，value的值不需要进行大小端转换，但其他带含义字段需要，比如key的长度
     */
    for (int i = 0; i< arrayCount; i++) {
        //key
        memcpy(&keyLen, sd, 2);
        keyLen = ntohs(keyLen);
        sd += 2;
        char *key = (char *)sd;
        NSLog(@"array map key: %s", key);
        sd += keyLen;
        
        //data
        dataType = *sd;
        sd++;
        //    0 = Number type   8字节
        //    1 = Boolean type  1字节
        //    2 = String type   相当于string，后面跟着2字节为长度
        //    3 = Object type
        //    4 = MovieClip type
        //    5 = Null type
        //    6 = Undefined type
        //    7 = Reference type
        //    8 = ECMA array type
        //    10 = Strict array type
        //    11 = Date type    SI16
        //    12 = Long string type
        uint16_t dataLen = 0;
        switch (dataType) {
            case 0:{ //Number double类型
                dataLen = 8;
                char cValue[8];
                char temp;
                //小端反转
                memcpy(&cValue, sd, dataLen);
                for (int i = 0; i < 4; i++) {
                    temp =  cValue[i];
                    cValue[i] = cValue[7-i];
                    cValue[7-i] = temp;
                }
                double value = *((double*)cValue);
                NSLog(@"[dataType = %d] array map value: %f", dataType, value);
            }
                break;
            case 1:{
                BOOL flag;
                //bool类型时，后面没有保存使用多少字节存储bool类型， 直接使用1字节
                dataLen = 1;
                memcpy(&flag, sd, dataLen);
                NSLog(@"[dataType = %d] array map value: %d",dataType, flag);
            }
                break;
            case 2:{
                memcpy(&dataLen, sd, 2);
                dataLen = ntohs(dataLen);
                sd += 2;
                char *s = (char *)malloc(dataLen);
                memcpy(s, sd, dataLen);
                NSLog(@"[dataType = %d] array map value: %s",dataType, s);
                free(s);
            }
                break;
            case 3:{
                memcpy(&dataLen, sd, 2);
                dataLen = ntohs(dataLen);
                sd += 2;
                char *s = (char *)malloc(dataLen);
                memcpy(s, sd, dataLen);
                NSLog(@"[dataType = %d] array map value: %s",dataType, s);
                free(s);
            }
                break;
            case 11:{
                memcpy(&dataLen, sd, 2);
                dataLen = ntohs(dataLen);
                sd += 2;
                char *s = (char *)malloc(dataLen);
                memcpy(s, sd, dataLen);
                NSLog(@"[dataType= %d] array map value: %s",dataType, s);
                free(s);
            }
                break;
            case 12:{
                memcpy(&dataLen, sd, 2);
                dataLen = ntohs(dataLen);
                sd += 2;
                char *s = (char *)malloc(dataLen);
                memcpy(s, sd, dataLen);
                NSLog(@"[dataType= %d] array map value: %s",dataType, s);
                free(s);
            }
                break;
            default:{
                memcpy(&dataLen, sd, 2);
                dataLen = ntohs(dataLen);
                sd += 2;
                char *s = (char *)malloc(dataLen);
                memcpy(s, sd, dataLen);
                NSLog(@"[dataType= %d] array map value: %s",dataType, s);
                free(s);
            }
                break;
        }
        sd += dataLen;
    }
    NSLog(@"-------------------ECMA array map end---------------------");
    NSLog(@"--------------ScriptData end--------------------");
    
}


void handleAutioTagData(uint8_t data) {
    NSString *formate = @"未知";          //音频格式：
    NSString *sampleRate = @"44-kHz"; // 采样率：AAC总是 44-kHz
    NSString *samplelen = @"snd16Bit"; //采样长度：压缩过的音频都是16Bit
    NSString *type = @"sndStereo"; //AAC总是1
    switch (data >> 4) {
        case 0:
            formate = @"Linear PCM, platform endian";
        case 1:
            formate = @"ADPCM";
        case 2:
            formate = @"MP3";
        case 3:
            formate = @"Linear PCM, little endian";
        case 4:
            formate = @"Nellymoser 16-kHz mono";
        case 5:
            formate = @"nellymoser 8-kHz mono";
        case 6:
            formate = @"nellymoser";
        case 7:
            formate = @"G.711 A-law logarithmic PCM";
        case 8:
            formate = @"G.711 mu-law logarithmic PCM";
        case 9:
            formate = @"reserved";
        case 10:
            formate = @"AAC";
        case 11:
            formate = @"Speex";
        case 14:
            formate = @"MP3 8-kHz";
        case 15:
            formate = @"Device-specific sound";
            break;
        default:
            break;
    }
    
    switch ((data >> 2) & 0x00f) {
        case 0:
            sampleRate = @"5.5-kHz";
        case 1:
            sampleRate = @"11-kHz";
        case 2:
            sampleRate = @"22-kHz";
        case 3:
            sampleRate = @"44-kHz";
            break;
        default:
            break;
    }
    
    switch ((data & 0xfff2) >> 1) {
        case 0:
            samplelen = @"snd8Bit";
            break;
        case 1:
            samplelen = @"snd16Bit";
            break;
        default:
            break;
    }
    
    switch ((data & 0xfff1)) {
        case 0:
            type = @"sndMono";
            break;
        case 1:
            type = @"sndStereo";
            break;
        default:
            break;
    }
    
    NSLog(@"audio: [formate]: %@, [sampleRate]: %@, [sampleRate]: %@, [type]: %@",formate,sampleRate, samplelen, type);
}


void handleVideoTagData(uint8_t data) {
    NSString *frame = @"未知";
    NSString *coder = @"未知";
    switch (data >> 4) {
        case 1:
            frame = @"keyframe(for AVC, a seekable frame)";
            break;
        case 2:
            frame = @"inter frame(for AVC, a non-seekable frame)";
            break;
        case 3:
            frame = @"disposable inter frame(H.263 only)";
            break;
        case 4:
            frame = @"generated keyframe (reserved for server use only)";
            break;
        case 5:
            frame = @"video info/command frame";
            break;
        default:
            break;
    }
    
    switch (data & 0x0f) {
        case 1:
            coder = @"JPEG(currenly unused)";
            break;
        case 2:
            coder = @"Sorenson H.263";
            break;
        case 3:
            coder = @"Screen video";
            break;
        case 4:
            coder = @"On2 VP6";
            break;
        case 5:
            coder = @"On2 VP6 with alpha channel";
            break;
        case 6:
            coder = @"Screen video version 2";
            break;
        case 7:
            coder = @"AVC";
            break;
        default:
            break;
    }
    NSLog(@"video: [frame]: %@, [coder]: %@", frame, coder);
    
}

@end
