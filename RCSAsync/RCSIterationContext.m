//
//  RCSIterationContext.m
//  RCSAsync
//
//  Created by Jim Roepcke on 2012-09-18.
//  Copyright (c) 2012 Roepcke Computing Solutions. All rights reserved.
//

#import "RCSIterationContext.h"
#import "RCSIteration.h"

@implementation RCSIterationContext

- (void)dealloc
{
    [_iteration release]; _iteration = nil;
    [_error release]; _error = nil;
    [super dealloc];
}

- (instancetype)next
{
    // TODO: keep track of the fact next was called, don't let it be called twice
    [self.iteration next:self];
    return self;
}

- (instancetype)stop
{
    // TODO: keep track of the fact stop was called, don't let it be called twice
    [self.iteration stop:self];
    return self;
}

- (instancetype)failed:(NSError *)error
{
    // TODO: keep track of the fact failed: was called, don't let it be called twice
    [self.iteration failed:self withError:error];
    return self;
}

+ (instancetype)contextFor:(RCSIteration *)iteration
                     index:(NSUInteger)index
                    length:(NSUInteger)length
                   isFirst:(BOOL)first
                    isLast:(BOOL)last
                 isStopped:(BOOL)stopped
                     error:(NSError *)error
{
    RCSIterationContext *result = [[[self alloc] init] autorelease];
    result->_iteration = [iteration retain];
    result->_index = index;
    result->_length = length;
    result->_first = first;
    result->_last = last;
    result->_stopped = stopped;
    result->_error = [error retain];
    return result;
}

- (instancetype)nextContext
{
    RCSIterationContext *nextContext = [[[[self class] alloc] init] autorelease];
    nextContext->_iteration = [self.iteration retain];
    nextContext->_index = self.index + 1;
    nextContext->_length = self.length;
    nextContext->_first = NO;
    nextContext->_last = self.index + 2 == self.length;
    nextContext->_stopped = NO;
    nextContext->_error = nil;
    return nextContext;
}

@end
