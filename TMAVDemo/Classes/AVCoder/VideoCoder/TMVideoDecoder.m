//
//  TMVideoDecoder.m
//  TMAVDemo
//
//  Created by 天明 on 2017/8/13.
//  Copyright © 2017年 天明. All rights reserved.
//

#import "TMVideoDecoder.h"
#import <AVFoundation/AVFoundation.h>
#import <VideoToolbox/VideoToolbox.h>

@interface TMVideoDecoder ()
@property (nonatomic, strong) dispatch_queue_t decodeQueue;
@property (nonatomic, strong) dispatch_queue_t callbackQueue;
/**解码会话*/
@property (nonatomic) VTDecompressionSessionRef decodeSesion;
@end
@implementation TMVideoDecoder {
    uint8_t *_sps;
    NSUInteger _spsSize;
    uint8_t *_pps;
    NSUInteger _ppsSize;
    CMVideoFormatDescriptionRef _decodeDesc;
}
/**解码回调函数*/
void videoDecompressionOutputCallback(void * CM_NULLABLE decompressionOutputRefCon,
                                      void * CM_NULLABLE sourceFrameRefCon,
                                      OSStatus status,
                                      VTDecodeInfoFlags infoFlags,
                                      CM_NULLABLE CVImageBufferRef imageBuffer,
                                      CMTime presentationTimeStamp, 
                                      CMTime presentationDuration ) {
    if (status != noErr) {
        NSLog(@"Video hard decode callback error status=%d", (int)status);
        return;
    }
    CVPixelBufferRef *outputPixelBuffer = (CVPixelBufferRef *)sourceFrameRefCon;
    *outputPixelBuffer = CVPixelBufferRetain(imageBuffer);
    TMVideoDecoder *decoder = (__bridge TMVideoDecoder *)(decompressionOutputRefCon);
    dispatch_async(decoder.callbackQueue, ^{
        [decoder.delegate videoDecodeCallback:imageBuffer];
        CVPixelBufferRelease(imageBuffer);
    });
}


- (instancetype)initWithConfig:(TMVideoConfig *)config
{
    self = [super init];
    if (self) {
        _config = config;
        _decodeQueue = dispatch_queue_create("h264 hard decode queue", DISPATCH_QUEUE_SERIAL);
        _callbackQueue = dispatch_queue_create("h264 hard decode callback queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

/*初始化解码器**/
- (BOOL)initDecoder {
    if (_decodeSesion) return true;
    const uint8_t * const parameterSetPointers[2] = {_sps, _pps};
    const size_t parameterSetSizes[2] = {_spsSize, _ppsSize};
    int naluHeaderLen = 4;
    
    /**
     根据sps pps设置解码参数
     param kCFAllocatorDefault 分配器
     param 2 参数个数
     param parameterSetPointers 参数集指针
     param parameterSetSizes 参数集大小
     param naluHeaderLen nalu nalu start code 的长度 4
     param _decodeDesc 解码器描述
     return 状态
     */
    OSStatus status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault, 2, parameterSetPointers, parameterSetSizes, naluHeaderLen, &_decodeDesc);
    if (status != noErr) {
        NSLog(@"Video hard DecodeSession create H264ParameterSets(sps, pps) failed status= %d", (int)status);
        return false;
    }
    NSDictionary *destinationPixBufferAttrs =
    @{
      (id)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange], //iOS上 nv12(uvuv排布) 而不是nv21（vuvu排布）
      (id)kCVPixelBufferWidthKey: [NSNumber numberWithInteger:_config.width],
      (id)kCVPixelBufferHeightKey: [NSNumber numberWithInteger:_config.height],
      (id)kCVPixelBufferOpenGLCompatibilityKey: [NSNumber numberWithBool:true]
      };
    //回调设置
    VTDecompressionOutputCallbackRecord callbackRecord;
    callbackRecord.decompressionOutputCallback = videoDecompressionOutputCallback;
    callbackRecord.decompressionOutputRefCon = (__bridge void * _Nullable)(self);
    //创建session
    status = VTDecompressionSessionCreate(kCFAllocatorDefault, _decodeDesc, NULL, (__bridge CFDictionaryRef _Nullable)(destinationPixBufferAttrs), &callbackRecord, &_decodeSesion);
    if (status != noErr) {
        NSLog(@"Video hard DecodeSession create failed status= %d", (int)status);
        return false;
    }
    //不支持 -12900
//    status = VTSessionSetProperty(_decodeSesion, kVTDecompressionPropertyKey_ThreadCount, (__bridge CFTypeRef _Nonnull)([NSNumber numberWithInt:1]));
//    NSLog(@"Vidoe hard decodeSession set property ThreadCount status = %d", (int)status);
    status = VTSessionSetProperty(_decodeSesion, kVTDecompressionPropertyKey_RealTime,kCFBooleanTrue);
    NSLog(@"Vidoe hard decodeSession set property RealTime status = %d", (int)status);
    return true;
}
/**解码函数（private）*/
- (CVPixelBufferRef)decode:(uint8_t *)frame withSize:(uint32_t)frameSize {
    
    CVPixelBufferRef outputPixelBuffer = NULL;
    CMBlockBufferRef blockBuffer = NULL;
    CMBlockBufferFlags flag0 = 0;
    //创建blockBuffer
    OSStatus status = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault, frame, frameSize, kCFAllocatorNull, NULL, 0, frameSize, flag0, &blockBuffer);
    if (status != kCMBlockBufferNoErr) {
        NSLog(@"Video hard decode create blockBuffer error code=%d", (int)status);
        return outputPixelBuffer;
    }
    
    CMSampleBufferRef sampleBuffer = NULL;
    const size_t sampleSizeArray[] = {frameSize};
    //创建sampleBuffer
    status = CMSampleBufferCreateReady(kCFAllocatorDefault, blockBuffer, _decodeDesc, 1, 0, NULL, 1, sampleSizeArray, &sampleBuffer);
    if (status != noErr || !sampleBuffer) {
        NSLog(@"Video hard decode create sampleBuffer failed status=%d", (int)status);
        CFRelease(blockBuffer);
        return outputPixelBuffer;
    }
    
    //解码
    VTDecodeFrameFlags flag1 = kVTDecodeFrame_1xRealTimePlayback;
    VTDecodeInfoFlags  infoFlag = kVTDecodeInfo_Asynchronous;
    status = VTDecompressionSessionDecodeFrame(_decodeSesion, sampleBuffer, flag1, &outputPixelBuffer, &infoFlag);
    if (status == kVTInvalidSessionErr) {
        NSLog(@"Video hard decode  InvalidSessionErr status =%d", (int)status);
    } else if (status == kVTVideoDecoderBadDataErr) {
       NSLog(@"Video hard decode  BadData status =%d", (int)status);
    } else if (status != noErr) {
        NSLog(@"Video hard decode failed status =%d", (int)status);
    }
    CFRelease(sampleBuffer);
    CFRelease(blockBuffer);

    return outputPixelBuffer;
}

// private
- (void)decodeNaluData:(uint8_t *)frame size:(uint32_t)size {
    int type = (frame[4] & 0x1F);
    uint32_t naluSize = size - 4;
    uint8_t *pNaluSize = (uint8_t *)(&naluSize);
    CVPixelBufferRef pixelBuffer = NULL;
    frame[0] = *(pNaluSize + 3);
    frame[1] = *(pNaluSize + 2);
    frame[2] = *(pNaluSize + 1);
    frame[3] = *(pNaluSize);
    switch (type) {
        case 0x05: //关键帧
            if ([self initDecoder]) {
                pixelBuffer= [self decode:frame withSize:size];
            }
            break;
        case 0x06:
            //NSLog(@"SEI");//增强信息
            break;
        case 0x07: //sps
            _spsSize = naluSize;
            _sps = malloc(_spsSize);
            memcpy(_sps, &frame[4], _spsSize);
            break;
        case 0x08: //pps
            _ppsSize = naluSize;
            _pps = malloc(_ppsSize);
            memcpy(_pps, &frame[4], _ppsSize);
            break;
        default: //其他帧（1-5）
            if ([self initDecoder]) {
                 pixelBuffer = [self decode:frame withSize:size];
            }
            break;
    }
}

// public
- (void)decodeNaluData:(NSData *)frame {
    dispatch_async(_decodeQueue, ^{
        uint8_t *nalu = (uint8_t *)frame.bytes;
        [self decodeNaluData:nalu size:(uint32_t)frame.length];
    });
}

//销毁
- (void)dealloc
{
    if (_decodeSesion) {
        VTDecompressionSessionInvalidate(_decodeSesion);
        CFRelease(_decodeSesion);
        _decodeSesion = NULL;
    }
   
}

/**
 nal_unit_type  NAL类型                         C
 0              未使用
 1              非IDR图像中不采用数据划分的片段     2,3,4
 2              非IDR图像中A类数据划分片段         2
 3              非IDR图像中B类数据划分片段         3
 4              非IDR图像中C类数据划分片段         4
 5              IDR图像的片                     2,3
 6              补充增强信息单元（SEI）           5
 7              序列参数集                       0
 8              图像参数集                       1
 9              分界符                          6
 10             序列结束                         7
 11             码流结束                        8
 12             填充                            9
 13..23         保留
 
 24..31        不保留（RTP打包时会用到）
 

 NSString * const naluTypesStrings[] =
 {
 @"0: Unspecified (non-VCL)",
 @"1: Coded slice of a non-IDR picture (VCL)",    // P frame
 @"2: Coded slice data partition A (VCL)",
 @"3: Coded slice data partition B (VCL)",
 @"4: Coded slice data partition C (VCL)",
 @"5: Coded slice of an IDR picture (VCL)",      // I frame
 @"6: Supplemental enhancement information (SEI) (non-VCL)",
 @"7: Sequence parameter set (non-VCL)",         // SPS parameter
 @"8: Picture parameter set (non-VCL)",          // PPS parameter
 @"9: Access unit delimiter (non-VCL)",
 @"10: End of sequence (non-VCL)",
 @"11: End of stream (non-VCL)",
 @"12: Filler data (non-VCL)",
 @"13: Sequence parameter set extension (non-VCL)",
 @"14: Prefix NAL unit (non-VCL)",
 @"15: Subset sequence parameter set (non-VCL)",
 @"16: Reserved (non-VCL)",
 @"17: Reserved (non-VCL)",
 @"18: Reserved (non-VCL)",
 @"19: Coded slice of an auxiliary coded picture without partitioning (non-VCL)",
 @"20: Coded slice extension (non-VCL)",
 @"21: Coded slice extension for depth view components (non-VCL)",
 @"22: Reserved (non-VCL)",
 @"23: Reserved (non-VCL)",
 @"24: STAP-A Single-time aggregation packet (non-VCL)",
 @"25: STAP-B Single-time aggregation packet (non-VCL)",
 @"26: MTAP16 Multi-time aggregation packet (non-VCL)",
 @"27: MTAP24 Multi-time aggregation packet (non-VCL)",
 @"28: FU-A Fragmentation unit (non-VCL)",
 @"29: FU-B Fragmentation unit (non-VCL)",
 @"30: Unspecified (non-VCL)",
 @"31: Unspecified (non-VCL)",
 };
 */

@end
