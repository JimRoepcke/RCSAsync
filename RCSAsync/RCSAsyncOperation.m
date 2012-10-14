//
//  RCSAsyncOperation.m
//  RCSAsync
//
//  Created by Jim Roepcke on 2012-10-08.
//  Copyright (c) 2012 Roepcke Computing Solutions. All rights reserved.
//

#import "RCSAsyncOperation.h"

@implementation RCSAsyncOperation
{
    BOOL _executing; // for concurrent NSOperation
    BOOL _finished; // for concurrent NSOperation
    dispatch_block_t _executionBlock;
    dispatch_queue_t _queue;
}

@synthesize executionBlock = _executionBlock;
@synthesize queue = _queue;

- (void)dealloc
{
    [_executionBlock release]; _executionBlock = nil;
    dispatch_release(_queue); _queue = NULL;
    [super dealloc];
}

+ (instancetype)execute:(void (^)(RCSAsyncOperation *operation))block
{
    __block RCSAsyncOperation *result = [[[[self class] alloc] init] autorelease];
    result.executionBlock = ^{
        block(result);
    };
    return result;
}

+ (instancetype)execute:(void (^)(RCSAsyncOperation *operation))block onQueue:(dispatch_queue_t)queue
{
    __block RCSAsyncOperation *result = [[[[self class] alloc] init] autorelease];
    result.executionBlock = ^{
        block(result);
    };
    result.queue = queue;
    return result;
}

- (id)initWithExecutionBlock:(dispatch_block_t)executionBlock onQueue:(dispatch_queue_t)queue
{
    self = [super init];
    if (self)
    {
        _executionBlock = [executionBlock copy];
        if (!queue)
        {
            queue = [self defaultQueue];
        }
        _queue = queue;
        dispatch_retain(_queue);
    }
    return self;
}

- (id)init
{
    self = [self initWithExecutionBlock:nil onQueue:nil];
    return self;
}

- (dispatch_queue_t)defaultQueue
{
    return dispatch_get_main_queue();
}

- (void)setQueue:(dispatch_queue_t)queue
{
    if (queue == nil)
    {
        queue = [self defaultQueue];
    }
    if (_queue != queue)
    {
        dispatch_release(_queue);
        dispatch_retain(queue);
        queue = _queue;
    }
}

- (void)start
{
    if ([self isCancelled])
    {
        [self willChangeValueForKey:@"isFinished"];
        _finished = YES;
        [self didChangeValueForKey:@"isFinished"];
    }
    else
    {
        [self main];
    }
}

- (void)main
{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];

    [self execute];
}

- (void)execute
{
    if (self.queue && self.executionBlock)
    {
        dispatch_async(self.queue, self.executionBlock);
    }
    else
    {
        [self done];
    }
}

#pragma mark -
#pragma mark Completing the operation

- (void)done
{
    [self willChangeValueForKey: @"isFinished"];
    [self willChangeValueForKey: @"isExecuting"];

    _executing = NO;
    _finished = YES;

    [self didChangeValueForKey: @"isExecuting"];
    [self didChangeValueForKey: @"isFinished"];
}

#pragma mark -
#pragma mark Concurrent NSOperation support

- (BOOL) isConcurrent { return YES; }
- (BOOL) isExecuting { return _executing; }
- (BOOL) isFinished  { return _finished; }

@end
