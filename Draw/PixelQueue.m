//
//  PixelQueue.m
//  Draw Calc
//
//  Created by Devan Kuleindiren on 18/09/2015.
//  Copyright (c) 2015 Devan Kuleindiren. All rights reserved.
//

#import "PixelQueue.h"

@interface PixelQueue () {
    NSMutableArray *queue;
}

@end

@implementation PixelQueue

- (PixelQueue *) init {
    self = [super init];
    
    if (self) {
        queue = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) push:(Pixel *)pixel {
    [queue addObject:pixel];
}

- (Pixel *) pull {
    Pixel *result = nil;
    if ([queue count] > 0) {
        result = [queue objectAtIndex:0];
        [queue removeObjectAtIndex:0];
    }
    return result;
}

- (BOOL) isEmpty {
    if ([queue count] > 0) {
        return NO;
    }
    return YES;
}

- (void) printQueue {
    NSLog(@"FRONT:");
    for (int i = 0; i < [queue count]; i++) {
        NSLog(@"%@", [queue objectAtIndex:i]);
    }
    NSLog(@"BACK \n");
}

- (int) count {
    return (int) [queue count];
}

@end
