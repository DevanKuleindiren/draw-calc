//
//  Debug.m
//  Draw Calc
//
//  Created by Devan Kuleindiren on 08/09/2015.
//  Copyright (c) 2015 Devan Kuleindiren. All rights reserved.
//

#import "Debug.h"

@implementation Debug

+ (void) drawRectBoundsWithLooseRect:(CGRect)looseRect tightRect:(CGRect)tightRect onImageView:(UIImageView *)iV inViewController:(UIViewController *)vC {
    UIGraphicsBeginImageContext(vC.view.frame.size);
    [iV.image drawInRect:CGRectMake(0, 0, vC.view.frame.size.width, vC.view.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    
    
    // Add tight rectangular bound
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 2);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 10.0, 0, 1.0);
    CGContextAddRect(UIGraphicsGetCurrentContext(), tightRect);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    
    // Add loose 28 multiple square bound
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 10);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 255, 0, 1.0);
    CGContextAddRect(UIGraphicsGetCurrentContext(), looseRect);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    
    CGContextFlush(UIGraphicsGetCurrentContext());
    iV.image = UIGraphicsGetImageFromCurrentImageContext();
}

+ (void) printMatrix:(Matrix *)M {
    NSMutableString *temp = [[NSMutableString alloc] init];
    int row, col = 0;
    for (NSMutableArray *a in M.matrix) {
        for (NSNumber *n in a) {
            [temp appendString:[NSString stringWithFormat:@"Matrix[%d][%d] = %@\n", row, col, n]];
            col++;
        }
        row++;
        [temp appendString:@"\n"];
    }
    NSLog(temp, nil);
}

+ (void) printMatrixIntValue:(Matrix *)M {
    NSMutableString *temp = [[NSMutableString alloc] init];
    int row, col = 0;
    for (NSMutableArray *a in M.matrix) {
        for (NSNumber *n in a) {
            [temp appendString:[NSString stringWithFormat:@"Matrix[%d][%d] = %d\n", row, col, [n intValue]]];
            col++;
        }
        row++;
    }
    NSLog(temp, nil);
}

+ (void) printMatrixIntValueFlat:(Matrix *)M {
    NSMutableString *temp = [[NSMutableString alloc] init];
    for (NSMutableArray *a in M.matrix) {
        for (NSNumber *n in a) {
            [temp appendString:[NSString stringWithFormat:@"%d,", [n intValue]]];
        }
    }
    NSLog(temp, nil);
}

@end
