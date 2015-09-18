//
//  PixelQueue.h
//  Draw Calc
//
//  Created by Devan Kuleindiren on 18/09/2015.
//  Copyright (c) 2015 Devan Kuleindiren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Pixel.h"

@interface PixelQueue : NSObject

- (PixelQueue *) init;
- (void) push:(Pixel *)pixel;
- (Pixel *) pull;
- (BOOL) isEmpty;
- (void) printQueue;
- (int) count;

@end
