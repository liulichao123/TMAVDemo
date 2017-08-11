//
//  LLCAudioDataQueue.h
//  AudioQueue使用me
//
//  Created by mac on 16/9/13.
//  Copyright © 2016年 刘立超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMAudioDataQueue : NSObject

@property (nonatomic, readonly) int count;

+(instancetype) shareInstance;

- (void)addData:(id)obj;

- (id)getData;
@end
