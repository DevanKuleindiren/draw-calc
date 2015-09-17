//
//  MutableStringStack.h
//  Draw Calc
//
//  Created by Devan Kuleindiren on 17/09/2015.
//  Copyright (c) 2015 Devan Kuleindiren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MutableStringStack : NSObject

- (MutableStringStack *) init;
- (void) push:(NSMutableString *) string;
- (NSMutableString *) pop;
- (NSMutableString *) head;
- (BOOL) isEmpty;
- (void) printStack;
- (int) count;

@end
