//
//  Pixel.h
//  Draw Calc
//
//  Created by Devan Kuleindiren on 18/09/2015.
//  Copyright (c) 2015 Devan Kuleindiren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Pixel : NSObject

@property (readonly) int x;
@property (readonly) int y;

- (Pixel *) initWithX:(int)x Y:(int)y;

@end
