//
//  UIImage+UIImage_PixelInteraction.m
//  Draw Calc
//
//  Created by Devan Kuleindiren on 09/09/2015.
//  Copyright (c) 2015 Devan Kuleindiren. All rights reserved.
//

#import "UIImage+UIImage_PixelInteraction.h"

@implementation UIImage (UIImage_PixelInteraction)

- (unsigned char *) extractRawImageData {
    
    CGImageRef imageRef = [self CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    NSLog(@"%lu", (unsigned long)width);
    NSLog(@"%lu", (unsigned long)height);
    NSLog(@"%lu", sizeof(rawData));
    
    return rawData;
}

- (Matrix *) extractRawImageDataFromX:(int)x fromY:(int)y with28Multiple:(int)multiple andInputNodesNo:(int)inputNodesNo {
    
    unsigned char *rawData = [self extractRawImageData];
    
    CGImageRef imageRef = [self CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    
    Matrix *inputVector = [[Matrix alloc] initWithRows:1 cols:inputNodesNo];
    Matrix *test = [[Matrix alloc] initWithRows:28 cols:28];
    
    for (int row = 0; row < 28; row++) {
        for (int col = 0; col < 28; col++) {
            double sum = 0;
            
            for (int subRow = 0; subRow < multiple; subRow++) {
                for (int subCol = 0; subCol < multiple; subCol++) {
                    NSUInteger byteIndex = (bytesPerRow * (y + (row * multiple) + subRow)) + ((x + (col * multiple) + subCol) * bytesPerPixel);
                    sum += rawData[byteIndex + 3];
                }
            }
            
            sum = floor(sum / (multiple * multiple));
            
            [test insertObjectAtRow:row col:col obj:[NSNumber numberWithDouble:sum]];
            [inputVector insertObjectAtRow:0 col:((row * 28) + col) obj:[NSNumber numberWithDouble:sum]];
        }
    }
    
    [inputVector insertObjectAtRow:0 col:(inputNodesNo - 1) obj:[NSNumber numberWithDouble:0]];
    [inputVector insertObjectAtRow:0 col:0 obj:[NSNumber numberWithDouble:-1]];
    free(rawData);
    
    return inputVector;
}



@end