//
//  FLVTags.h
//  TMAVDemo
//
//  Created by 天明 on 2017/8/16.
//  Copyright © 2017年 天明. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLV_Header : NSObject
@property (nonatomic, assign, readonly) int8_t f;
@property (nonatomic, assign, readonly) int8_t l;
@property (nonatomic, assign, readonly) int8_t v;
@property (nonatomic, assign, readonly) int8_t vertion;
@property (nonatomic, assign, readonly) int8_t flag;
@property (nonatomic, assign, readonly) uint32_t headerSize; //4 byte =9
- (int)length;
- (NSData *)toBigData;
+ (FLV_Header *)header;
@end


