//
//  RCSArrayIterationContext.m
//  RCSAsync
//
//  Created by Jim Roepcke on 2012-09-18.
//  Copyright (c) 2012 Roepcke Computing Solutions. All rights reserved.
//

#import "RCSArrayIterationContext.h"

@implementation RCSArrayIterationContext

@dynamic iteration; // inherit ivar from superclass

- (RCSArrayIteration *)iteration
{
    return (RCSArrayIteration *)[super iteration];
}

- (void)dealloc
{
    [_object release]; _object = nil;
    [_eachBlock release]; _eachBlock = nil;
    [_completionBlock release]; _completionBlock = nil;
    [_failureBlock release]; _failureBlock = nil;
    [super dealloc];
}

+ (instancetype)contextFor:(RCSArrayIteration *)iteration
                     index:(NSUInteger)index
                    length:(NSUInteger)length
                    object:(id)object
                   isFirst:(BOOL)first
                    isLast:(BOOL)last
                 isStopped:(BOOL)stopped
                     error:(NSError *)error
                 eachBlock:(RCSArrayIterationEachBlock)eachBlock
           completionBlock:(RCSArrayIterationCompletionBlock)completionBlock
              failureBlock:(RCSArrayIterationFailureBlock)failureBlock
{
    RCSArrayIterationContext *result = [self contextFor:iteration index:index length:length isFirst:first isLast:last isStopped:stopped error:error];
    result->_object = [object retain];
    result->_eachBlock = Block_copy(eachBlock);
    result->_completionBlock = Block_copy(completionBlock);
    result->_failureBlock = Block_copy(failureBlock);
    return result;
}

- (instancetype)nextContextWithObject:(id)nextObject
{
    RCSArrayIterationContext *nextContext = [self nextContext];
    nextContext->_object = [nextObject retain];
    nextContext->_eachBlock = [self.eachBlock retain];
    nextContext->_completionBlock = [self.completionBlock retain];
    nextContext->_failureBlock = [self.failureBlock retain];
    return nextContext;
}

@end
