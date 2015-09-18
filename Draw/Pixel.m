//
//  Pixel.m
//  Draw Calc
//
//  Created by Devan Kuleindiren on 18/09/2015.
//  Copyright (c) 2015 Devan Kuleindiren. All rights reserved.
//

#import "Pixel.h"

@implementation Pixel

- (Pixel *) initWithX:(int)x Y:(int)y {
    self = [super init];
    
    if (self) {
        _x = x;
        _y = y;
    }
    
    return self;
}

@end
