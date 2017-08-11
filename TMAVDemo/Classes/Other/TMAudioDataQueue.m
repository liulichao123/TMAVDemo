//
//  LLCAudioDataQueue.m
//  AudioQueue使用me
//
//  Created by mac on 16/9/13.
//  Copyright © 2016年 刘立超. All rights reserved.
//

#import "TMAudioDataQueue.h"

@interface TMAudioDataQueue ()
@property (nonatomic, strong) NSMutableArray *bufferArray;
@end

@implementation TMAudioDataQueue

@synthesize count;

static TMAudioDataQueue *_instance = nil;

+(instancetype) shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    }) ;
    return _instance ;
}

- (instancetype)init{
    if (self = [super init]) {
        _bufferArray = [NSMutableArray array];
        count = 0;
    }
    return self;
}

-(void)addData:(id)obj{
    @synchronized (_bufferArray) {
        [_bufferArray addObject:obj];
        count = (int)_bufferArray.count;
    }
}

- (id)getData{
    @synchronized (_bufferArray) {
        id obj = nil;
        if (count) {
            obj = [_bufferArray firstObject];
            [_bufferArray removeObject:obj];
            count = (int)_bufferArray.count;
        }
        return obj;
    }
}
@end
