//
//  RCSIndexSetIterationContext.m
//  RCSAsync
//
//  Created by Jim Roepcke on 2012-09-16.
//  Copyright (c) 2012 Roepcke Computing Solutions. All rights reserved.
//

#import "RCSIndexSetIterationContext.h"
#import "RCSIndexSetIteration.h"

@implementation RCSIndexSetIterationContext

@dynamic iteration; // inherit ivar from superclass

- (RCSIndexSetIteration *)iteration
{
    return (RCSIndexSetIteration *)[super iteration];
}

- (void)dealloc
{
    [_eachBlock release]; _eachBlock = nil;
    [_completionBlock release]; _completionBlock = nil;
    [_failureBlock release]; _failureBlock = nil;
    [super dealloc];
}

+ (instancetype)contextFor:(RCSIndexSetIteration *)iteration
                     index:(NSUInteger)index
                    length:(NSUInteger)length
                       idx:(NSUInteger)idx
                   isFirst:(BOOL)first
                    isLast:(BOOL)last
                 isStopped:(BOOL)stopped
                     error:(NSError *)error
                 eachBlock:(RCSIndexSetIterationEachBlock)eachBlock
           completionBlock:(RCSIndexSetIterationCompletionBlock)completionBlock
              failureBlock:(RCSIndexSetIterationFailureBlock)failureBlock
{
    RCSIndexSetIterationContext *result = [self contextFor:iteration index:index length:length isFirst:first isLast:last isStopped:stopped error:error];
    result->_idx = idx;
    result->_eachBlock = Block_copy(eachBlock);
    result->_completionBlock = Block_copy(completionBlock);
    result->_failureBlock = Block_copy(failureBlock);
    return result;
}

- (instancetype)nextContextWithIndex:(NSUInteger)nextIndex
{
    RCSIndexSetIterationContext *nextContext = [self nextContext];
    nextContext->_idx = nextIndex;
    nextContext->_eachBlock = [self.eachBlock retain];
    nextContext->_completionBlock = [self.completionBlock retain];
    nextContext->_failureBlock = [self.failureBlock retain];
    return nextContext;
}

@end
