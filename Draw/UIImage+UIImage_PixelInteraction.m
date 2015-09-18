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
    NSUInteger bytesPerPixel = 4;
    unsigned char *rawData = (unsigned char*) calloc(height * width * bytesPerPixel, sizeof(unsigned char));
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    return rawData;
}

- (int) getPixelFromRawData:(unsigned char *)rawData x:(int)x y:(int)y {
    if (x < 0 || x >= self.size.width || y < 0 || y >= self.size.height) {
        return 0;
    }
    return rawData[((y * 4 * (int) self.size.width) + (x * 4)) + 3];
}

- (int) getPixelFromRawData:(unsigned char *)rawData x:(int)x y:(int)y withLabel:(unsigned char)label {
    if (x >= 0 && x < self.size.width && y >= 0 && y < self.size.height && rawData[(y * 4 * (int) self.size.width) + (x * 4)] == label) {
        return rawData[((y * 4 * (int) self.size.width) + (x * 4)) + 3];
    }
    return 0;
}

- (int) getLabelFromRawData:(unsigned char *)rawData x:(int)x y:(int)y {
    if (x < 0 || x >= self.size.width || y < 0 || y >= self.size.height) {
        return 0;
    }
    return rawData[(y * 4 * (int) self.size.width) + (x * 4)];
}

- (void) setLabelInRawData:(unsigned char *)rawData x:(int)x y:(int)y value:(unsigned char)value {
    if (x >= 0 && x < self.size.width && y >= 0 && y < self.size.height) {
        rawData[(y * 4 * (int) self.size.width) + (x * 4)] = value;
    }
}

- (Matrix *) extractInputVectorFromRawData:(unsigned char *)rawData fromX:(int)x fromY:(int)y with28Multiple:(int)multiple inputNodesNo:(int)inputNodesNo label:(unsigned char)label {
    
    Matrix *inputVector = [[Matrix alloc] initWithRows:1 cols:inputNodesNo];
    Matrix *test = [[Matrix alloc] initWithRows:28 cols:28];
    
    for (int row = 0; row < 28; row++) {
        for (int col = 0; col < 28; col++) {
            double sum = 0;
            
            for (int subRow = 0; subRow < multiple; subRow++) {
                for (int subCol = 0; subCol < multiple; subCol++) {
                    //NSUInteger byteIndex = (bytesPerRow * (y + (row * multiple) + subRow)) + ((x + (col * multiple) + subCol) * bytesPerPixel);
                    //sum += rawData[byteIndex + 3];
                    sum += [self getPixelFromRawData:rawData x:(x + (col * multiple) + subCol) y:(y + (row * multiple) + subRow) withLabel:label];
                }
            }
            
            sum = floor(sum / (multiple * multiple));
            
            [test insertObjectAtRow:row col:col obj:[NSNumber numberWithDouble:sum]];
            [inputVector insertObjectAtRow:0 col:((row * 28) + col) obj:[NSNumber numberWithDouble:sum]];
        }
    }
    
    [inputVector insertObjectAtRow:0 col:(inputNodesNo - 1) obj:[NSNumber numberWithDouble:0]];
    [inputVector insertObjectAtRow:0 col:0 obj:[NSNumber numberWithDouble:-1]];
    
    return inputVector;
}

- (double *) labelConnectedComponentsIn:(unsigned char *) rawData {
    
    // There can be a maximum of 64 labels
    double *labels = (double*) calloc(64 * 3, sizeof(double));
    
    int currentLabel = 1;
    for (int y = 0; y < self.size.height; y++) {
        for (int x = 0; x < self.size.width; x++) {
            if ([self getPixelFromRawData:rawData x:x y:y] > 0 && [self getLabelFromRawData:rawData x:x y:y] == 0) {
                [self setLabelInRawData:rawData x:x y:y value:currentLabel];
                labels[(currentLabel * 3) + 1] = ((labels[(currentLabel * 3) + 1] * labels[currentLabel * 3]) + x) / (labels[currentLabel * 3] + 1);
                labels[(currentLabel * 3) + 2] = ((labels[(currentLabel * 3) + 2] * labels[currentLabel * 3]) + y) / (labels[currentLabel * 3] + 1);
                labels[currentLabel * 3]++;
                PixelQueue *neighbourQ = [[PixelQueue alloc] init];
                [neighbourQ push:[[Pixel alloc] initWithX:x Y:y]];
                
                // Label all other connected components with same label
                while (![neighbourQ isEmpty]) {
                    Pixel *current = [neighbourQ pull];
                    for (int yDiff = current.y - 1; yDiff <= current.y + 1; yDiff++) {
                        for (int xDiff = current.x - 1; xDiff <= current.x + 1; xDiff++) {
                            if ([self getPixelFromRawData:rawData x:xDiff y:yDiff] > 0 && [self getLabelFromRawData:rawData x:xDiff y:yDiff] == 0) {
                                [self setLabelInRawData:rawData x:xDiff y:yDiff value:currentLabel];
                                labels[(currentLabel * 3) + 1] = ((labels[(currentLabel * 3) + 1] * labels[currentLabel * 3]) + xDiff) / (labels[currentLabel * 3] + 1);
                                labels[(currentLabel * 3) + 2] = ((labels[(currentLabel * 3) + 2] * labels[currentLabel * 3]) + yDiff) / (labels[currentLabel * 3] + 1);
                                labels[currentLabel * 3]++;
                                [neighbourQ push:[[Pixel alloc] initWithX:xDiff Y:yDiff]];
                            }
                        }
                    }
                }
                
                currentLabel++;
            }
        }
    }
    
    return labels;
}



@end