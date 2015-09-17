//
//  MutableStringStack.m
//  Draw Calc
//
//  Created by Devan Kuleindiren on 17/09/2015.
//  Copyright (c) 2015 Devan Kuleindiren. All rights reserved.
//

#import "MutableStringStack.h"

@interface MutableStringStack() {
    NSMutableArray *stack;
}
@end

@implementation MutableStringStack

- (MutableStringStack *) init {
    self = [super init];
    
    if (self) {
        stack = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) push:(NSMutableString *)string {
    [stack addObject:string];
}

- (NSMutableString *) pop {
    NSMutableString *result = [stack lastObject];
    [stack removeLastObject];
    
    return result;
}

- (NSMutableString *) head {
    return [stack lastObject];
}

- (BOOL) isEmpty {
    if ([stack count] > 0) {
        return NO;
    }
    return YES;
}

- (void) printStack {
    NSLog(@"TOP:");
    for (int i = (int) [stack count] - 1; i >= 0; i--) {
        NSLog(@"%@", [stack objectAtIndex:i]);
    }
    NSLog(@"BOTTOM \n");
}

- (int) count {
    return (int) [stack count];
}

@end
